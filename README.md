# Fleet Unit Templates

This is a collection of Fleet unit files as `m4` templates. 

## Background

Fleet units are a great way to bootstrap a cluster with backing services or more advanced cluster managers like Kubernetes. The problem with units is that they are not very re-usuable if you need to co-deploy `N` versions for different tennants. Using `m4` we can generalize & parameterize fleet units to make them more re-usable.


## Sample Usage

    /usr/bin/m4 -DDOCKER_VOLUME={{/vol/replicated/assets/:/var/www/html}} \
                -DRSYNC_USERNAME={{nobody}} \
                -DRSYNC_PASSWORD={{super-secret}} \
                -DRSYNC_VOLUME={{/var/www/html/}} \
                -DRSYNC_NAME={{%i}} \
                -DRSYNC_READ_ONLY={{true}} \
                -DRSYNC_TIMEOUT={{60}} \
                -DRSYNC_MAX_CONNECTIONS={{10}} \
                -DFLEET_MACHINE_OF={{durable-storage}} \
                -DDNS_SERVICE_NAME={{rsync/rsyncd}} \
                -DDNS_SERVICE_ID={{assets/%m}} \
                -DDOCKER_NAME={{rsyncd_assets}} \
                    /fleet-units/rsyncd.service.m4  > /fleet-units/rsyncd.service


## Best Practices

* Use `Restart=always` in [Service] declarations for services
* Use `EnvironmentFile=/etc/environment` to access environment including `$COREOS_PRIVATE_IPV4`


 
