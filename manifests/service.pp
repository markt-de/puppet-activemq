# @summary Setup ActiveMQ multi-instance system service
#
# This manages the main system service. It is the base for all
# instance-specific service instances.
#
# @api private
class activemq::service {
  # Install service file for multi-instance support.
  file { $activemq::service_file:
    ensure  => file,
    owner   => 'root',
    group   => 0,
    mode    => '0644',
    content => epp($activemq::service_template),
  }

  # Enable main service.
  service { "${activemq::service_name}@":
    enable    => $activemq::service_enable,
    subscribe => [
      Class['activemq::install'],
    ],
    require   => [
      File[$activemq::service_file],
    ],
  }
}
