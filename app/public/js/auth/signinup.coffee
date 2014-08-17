(($) ->
    class Auth
        @signin: (userObj, callback) ->
            $.ajax({
                type: 'POST'
                url: '/signin'
                data: userObj
            }).done (responseData) ->
                callback?(JSON.parse(responseData))

        @signup: (userObj, callback) ->
            $.ajax({
                type: 'POST'
                url: '/signup'
                data: userObj
            }).done( (responseData) ->
                callback?(JSON.parse(responseData))
            )
    $('document').ready ->
        $('.login').click (event) ->
            user = {
                username: $('#username').val()
                password: $('#password').val()
            }
            Auth.signin user, (response)->
                console.log(response)
                if response.success
                    location.href = '/addressbook'
                else
                    location.href = '/signinup'

        $('.signup').click( (event) ->
            user = {
                username: $('#username').val()
                password: $('#password').val()
            }
            Auth.signup(user, (response) ->
                console.log(response)
                if response.success
                    location.href = '/addressbook'
                else
                    location.href = '/signinup'
            )
        )

) jQuery
