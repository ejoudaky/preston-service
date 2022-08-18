##
# You should look at the following URL's in order to grasp a solid understanding
# of Nginx configuration files in order to fully unleash the power of Nginx.
# https://www.nginx.com/resources/wiki/start/
# https://www.nginx.com/resources/wiki/start/topics/tutorials/config_pitfalls/
# https://wiki.debian.org/Nginx/DirectoryStructure
#
# In most cases, administrators will remove this file from sites-enabled/ and
# leave it as reference inside of sites-available where it will continue to be
# updated by the nginx packaging team.
#
# This file will automatically load configuration files provided by other
# applications, such as Drupal or Wordpress. These applications will be made
# available underneath a path with that package name, such as /drupal8.
#
# Please see /usr/share/doc/nginx-doc/examples/ for more detailed examples.
##

# Virtual Host configuration for example.com
#
# You can move that to a different file under sites-available/ and symlink that
# to sites-enabled/ to enable it.
#
proxy_cache_path /var/cache/nginx/preston/ levels=1:2 keys_zone=preston_cache:10m
                 max_size=200g inactive=1M use_temp_path=off;


server {

    server_name repo.jhpoelen.nl deeplinker.bio linker.bio;

    root /var/lib/preston/archives;
    index index.html;

    merge_slashes off;

    location ~ "/\.well-known/genid/" {
	return 302 https://www.w3.org/TR/rdf11-concepts/#section-skolemization;
    }

    # possibly a sha256 hash in hex notation
    location ~ "(hash://sha256/){0,1}[0-9a-f]{64}$" {
        proxy_cache preston_cache;
        proxy_pass http://localhost:8082;
    }

    # possibly a md5 hash in hex notation
    location ~ "(hash://md5/){0,1}[0-9a-f]{32}$" {
        proxy_cache preston_cache;
        proxy_pass http://localhost:8081;
    }

    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/deeplinker.bio/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/deeplinker.bio/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}

server {
    if ($host = repo.jhpoelen.nl) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


	listen 80;
	listen [::]:80;

	server_name repo.jhpoelen.nl;
    return 404; # managed by Certbot


}
