# This file is only an example. Please see the README.md for more info

module "drone" {
  source = "./drone"
  user_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/eADYZQ1gUrxP4sfHi/H07dm9M0KnjYnmcY1Ek8rrPzR1gCEsC+JThZC446AdKHbsNHOIlo+XL5yNYwHKRwKgtnE0uGQi/yJNQvxQpE1fqp/cCRQxoJZ34DJkO0HJAtq4miU/dMLTsmLSDR6VOB10SDF7kwMxpSveOrBBMe0dj/MgtlnQSJJBSpb/rfwCq0EWTmajcgx21F8/msBak/isPPYSi6IlKMwgSTbV4xjDsTcjww0BpyiWoUCw2CE9fDeZw5PdHqWXo895ENVtcHf9FdM8JoZks8mHLEnu5B813Ez+nWS9eJjwWmZq5LmIyVHJCrEohUcS8hX/qWErEfDX dgonzalez@Davids-iMac.local"
  drone_security_groups = ["sg-799ac311"]
}

output "drone-ip" {
  value = "${module.drone.drone-ip}"
}
