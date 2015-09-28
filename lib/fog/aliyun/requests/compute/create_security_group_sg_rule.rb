module Fog
  module Compute
    class Aliyun
      class Real
        def create_security_group_sg_rule(securitygroup_id, source_securyitgroup_id, option={})

          action   = 'AuthorizeSecurityGroup'
          sigNonce = randonStr()
          time     = Time.new.utc

          parameters = defalutParameters(action, sigNonce, time)
          pathUrl    = defaultAliyunUri(action, sigNonce, time)
          
          parameters["SecurityGroupId"] = securitygroup_id
          pathUrl += '&SecurityGroupId='
          pathUrl += securitygroup_id

          parameters["SourceGroupId"] = source_securyitgroup_id
          pathUrl += '&SourceGroupId='
          pathUrl += source_securyitgroup_id

          nicType = 'intranet'  #��ȫ�黥����Ȩ�̶���������Ȩģʽ
          parameters["NicType"] = nicType
          pathUrl += '&NicType='
          pathUrl += nicType
          
          #�˿ڷ�Χ��ѡ��ȱʡΪ���ж˿�
          portRange = option[:portRange]
          unless portRange
            portRange = '-1/-1'
          end
          parameters["PortRange"] = portRange
          pathUrl += '&PortRange='
          pathUrl += URI.encode(portRange,'/[^!*\'()\;?:@#&%=+$,{}[]<>`" ')
          
          #Э������(tcp/udp��)��ѡ��ȱʡΪ����Э��
          protocol = option[:protocol]
          unless protocol
            protocol = 'all'
          end
          parameters["IpProtocol"] = protocol
          pathUrl += '&IpProtocol='
          pathUrl += protocol

          signature = sign(@aliyun_accesskey_secret, parameters)
          pathUrl += '&Signature='
          pathUrl += signature

          request(
            :expects  => [200, 203],
            :method   => 'GET',
            :path     => pathUrl
          )
        end
      end

      class Mock
        def create_security_group_rule(parent_group_id, ip_protocol, from_port, to_port, cidr, group_id=nil)
          parent_group_id = parent_group_id.to_i
          response = Excon::Response.new
          response.status = 200
          response.headers = {
            'X-Compute-Request-Id' => "req-#{Fog::Mock.random_hex(32)}",
            'Content-Type'   => 'application/json',
            'Content-Length' => Fog::Mock.random_numbers(3).to_s,
            'Date' => Date.new
          }
          rule = {
            'id' => Fog::Mock.random_numbers(2).to_i,
            'from_port'   => from_port,
            'group'       => group_id || {},
            'ip_protocol' => ip_protocol,
            'to_port'     => to_port,
            'parent_group_id' => parent_group_id,
            'ip_range' => {
              'cidr'   => cidr
            }
          }
          self.data[:security_groups][parent_group_id.to_s]['rules'].push(rule)
          response.body = {
            'security_group_rule' => rule
          }
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog