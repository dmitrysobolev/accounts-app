'use strict'

SSOLoginController = (
  $log
  $state
  $stateParams
  $window
  $authService
  AuthService
  TokenService
  Utils) ->
  
  vm               = this
  vm.loading       = false
  vm.success       = false
  vm.error         = ''
  vm.emailOrHandle = ''
  vm.org           = $stateParams.org
  vm.retUrl        = $stateParams.retUrl

  activate = ->
    if vm.org
      go()

  vm.submit = ->
    vm.loading = true

    success = (org) ->
      vm.org     = org
      vm.success = true
      go()

    failure = (err) ->
      vm.loading = false
      vm.error   = err.message

    AuthService.getSSOProvider(vm.emailOrHandle).then(success).catch(failure)


  loginSuccess = ->
    jwt = TokenService.getAppirioJWT()
    if vm.retUrl
      redirectUrl = Utils.generateReturnUrl vm.retUrl
      $log.info 'redirect back to ' + redirectUrl
      $window.location = redirectUrl
    else
        $state.go 'home'
  
  go = ->
    callbackUrl = $state.href 'SSO_CALLBACK', {}, { absolute: true }
    state = vm.retUrl
    unless state
      # TODO: home?
      state = $state.href 'home', {}, { absolute: true }
      
    authUrl = Utils.generateSSOUrl vm.org, callbackUrl, state
    $log.info 'redirecting to ' + authUrl
    $window.location.href = authUrl;
  
  activate()

  vm

SSOLoginController.$inject = [
  '$log'
  '$state'
  '$stateParams'
  '$window'
  '$authService'
  'AuthService'
  'TokenService'
  'Utils'
]

angular.module('accounts').controller 'SSOLoginController', SSOLoginController

