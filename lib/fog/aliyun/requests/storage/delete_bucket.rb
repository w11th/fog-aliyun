module Fog
  module Storage
    class Aliyun
      class Real
        # Delete an existing bucket
        #
        # ==== Parameters
        # * bucket<~String> - Name of bucket to delete
        #
        def delete_bucket(bucket)
          location = get_bucket_location(bucket)
          endpoint = build_endpoint(location)
          resource = bucket + '/'
          request(
            expects: 204,
            method: 'DELETE',
            bucket: bucket,
            resource: resource,
            endpoint: endpoint
          )
        end
      end

      class Mock
        def delete_bucket(bucket)
        end
      end
    end
  end
end
