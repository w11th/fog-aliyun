module Fog
  module Storage
    class Aliyun
      class Real
        def list_objects(options = {})
          bucket = options[:bucket]
          bucket ||= @aliyun_oss_bucket
          prefix = options[:prefix]
          marker = options[:marker]
          maxKeys = options[:maxKeys]
          delimiter = options[:delimiter]

          path = ''
          if prefix
            path += '?prefix=' + prefix
            path += '&marker=' + marker if marker
            path += '&max-keys=' + maxKeys if maxKeys
            path += '&delimiter=' + delimiter if delimiter

          elsif marker
            path += '?marker=' + marker
            path += '&max-keys=' + maxKeys if maxKeys
            path += '&delimiter=' + delimiter if delimiter

          elsif maxKeys
            path += '?max-keys=' + maxKeys
            path += '&delimiter=' + delimiter if delimiter
          elsif delimiter
            path += '?delimiter=' + delimiter
          end

          location = get_bucket_location(bucket)
          endpoint = build_endpoint(location)
          resource = bucket + '/'
          ret = request(
            expects: [200, 203, 400],
            method: 'GET',
            path: path,
            resource: resource,
            bucket: bucket
          )
          xml = ret.data[:body]
          result = XmlSimple.xml_in(xml)
        end

        def list_multipart_uploads(bucket, endpoint, _options = {})
          if nil == endpoint
            location = get_bucket_location(bucket)
            endpoint = build_endpoint(location)
          end
          path = '?uploads'
          resource = bucket + '/' + path

          ret = request(
            expects: 200,
            method: 'GET',
            path: path,
            bucket: bucket,
            resource: resource,
            endpoint: endpoint
          )
          uploadid = XmlSimple.xml_in(ret.data[:body])['Upload']
        end

        def list_parts(bucket, object, endpoint, uploadid, _options = {})
          if nil == endpoint
            location = get_bucket_location(bucket)
            endpoint = build_endpoint(location)
          end
          path = object + '?uploadId=' + uploadid
          resource = bucket + '/' + path

          ret = request(
            expects: 200,
            method: 'GET',
            path: path,
            bucket: bucket,
            resource: resource,
            endpoint: endpoint
          )
          parts = XmlSimple.xml_in(ret.data[:body])['Part']
        end
      end

      class Mock
        def list_objects(options = {})
        end
      end
    end
  end
end
