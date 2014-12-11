name             "monitor"
maintainer       "Shrikant Patnaik"
maintainer_email "me@5p.io"
license          "Apache 2.0"
description      "A cookbook for monitoring services, using Sensu, a monitoring framework."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.5"

%w[
  ubuntu
  debian
  centos
  redhat
  fedora
].each do |os|
  supports os
end

depends "sensu", "1.0.0"
depends "sudo"
depends "uchiwa"
