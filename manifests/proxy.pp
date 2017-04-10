class sonarqube::proxy {
	  # proxy setting validation
  # must define host and port 
  if !empty($http_proxy) {
    if has_key($http_proxy, 'port') and has_key($http_proxy, 'host') {
      if $http_proxy['port'] == '' or $http_proxy['host'] == '' {
        fail('When defining http_proxy hash, both host and port are mandatory')
      }
    } else {
      fail('When defining http_proxy hash, both host and port are mandatory')
    }
  }

  if !empty($https_proxy) {
    if has_key($https_proxy, 'port') and has_key($https_proxy, 'host') {
      if $https_proxy['port'] == '' or $https_proxy['host'] == '' {
        fail('When defining http_proxy hash, both host and port are mandatory')
      }
    } else {
      fail('When defining http_proxy hash, both host and port are mandatory')
    }
  }

  # http_proxy and https_proxy port cannot be the same
  if has_key($http_proxy, 'port') and has_key($https_proxy, 'port') {
    if $http_proxy['port'] == $https_proxy['port'] {
      fail('When both defining http_proxy and https_proxy hashes, you cannot use the same port number !')
    }
  }
  # end proxy vaildation

}