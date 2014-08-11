### List Page Controller ###
(($) ->
    validateData = (data, fields) ->
        err = []
        for field in fields
            if data[field] == ''
                err.push(field)
        if err.length > 0
            return {success: false, err: err}
        else
            return {success: true}

    clearError = (fields) ->
        for field in fields
            $("." + field + "-msg").text('')

    String.prototype.removeQuotes = () ->
        if @[0] == '"' and @[@length-1] == '"'
            return @substr(1, @length-2)

    $("document").ready( ()->
        addBtn = $('.addRecord')
        recordRow = $('.recordRow')
        addBtn.click( (event) ->
            recordRow.removeClass('hide')
            addBtn.hide()
        )

        submitBtn = $('.imsure')
        submitBtn.click( (event) ->
            validationFields = ['name', 'location', 'company', 'phone1']
            recordRow = submitBtn.parents('.recordRow')
            _id = recordRow.attr('data-id')
            data = {
                _id: _id
                name: $('input[name="name"]').val()
                location: $('input[name="location"]').val()
                company: $('input[name="company"]').val()
                phone1: $('input[name="phone1"]').val()
                phone2: $('input[name="phone2"]').val()
            }
            msg = validateData(data, validationFields)
            if msg.success == false
                clearError(validationFields)
                for field in msg.err
                    $("."+field+"-msg").text('required').css('color', 'red')
            else
                successCallback = ->
                    location.href = '/addressbook'
                failureCallback = ->
                    alert("Failed when updating user")
                $.ajax({
                    type: "POST"
                    url: "/addressbook/update"
                    data: data
                }).done( (responseData) ->
                    console.log(responseData)
                    response = JSON.parse(responseData)
                    if response.success?
                        successCallback()
                    else
                        failureCallback()
                )
        )
        $('table').on('click', '.edit', (event) ->
            fields = ['name', 'location', 'company', 'phone1', 'phone2']
            target = $(event.target)
            row = target.parents('tr')
            console.log(target)
            for field in fields
                control = row.find('.' + field)
                text = control.text()
                input = $('<input/>').attr('type', 'text')
                    .val(text).attr('name', field)
                    .appendTo(control.parent())
                $('<br/>').appendTo(control.parent())
                $('<p/>').addClass(field+"-msg").appendTo(control.parent())
                control.remove()
            target.text('确定').removeClass('edit').addClass('update')
            target.click( (event) ->
                validationFields = ['name', 'location', 'company', 'phone1']
                _id = row.attr('data-id')
                if _id[0] == '"'
                    _id = _id.substr(1, _id.length-2)
                data = {
                    _id: _id
                    name: row.find('input[name="name"]').val()
                    location: row.find('input[name="location"]').val()
                    company: row.find('input[name="company"]').val()
                    phone1: row.find('input[name="phone1"]').val()
                    phone2: row.find('input[name="phone2"]').val()
                }
                msg = validateData(data, validationFields)
                if msg.success == false
                    clearError(validationFields)
                    console.log(msg)
                    for field in msg.err
                        row.find("."+field+"-msg").text('required').css('color', 'red')
                else
                    successCallback = ->
                        location.href = '/addressbook'
                    failureCallback = ->
                        alert("Failed when updating user")
                    $.ajax({
                        type: "POST"
                        url: "/addressbook/update"
                        data: data
                    }).done( (responseData) ->
                        console.log(responseData)
                        response = JSON.parse(responseData)
                        if response.success?
                            successCallback()
                        else
                            failureCallback()
                    )
            )
        )
        $('.mobai').click( (event) ->
            _target = $(event.target)
            starToggle = (handler) ->
                starControl = handler.parents('tr').find('.stars')
                stars = parseInt(starControl.text())
                if handler.hasClass('starred')
                    # should remove state of star
                    handler.text('膜拜')
                    starControl.text(stars - 1)
                else
                    # should add state of star
                    handler.text('取消')
                    starControl.text(stars + 1)
                handler.toggleClass('starred btn-primary btn-success')
            $.ajax({
                type: 'POST'
                url: '/user/star'
                data: {
                    _id: _target.parents('tr').attr('data-id').removeQuotes()
                    toggle: true
                }
            }).done( (responseData) ->
                response = JSON.parse(responseData)
                unless response.success
                    # should notify and handle error
                    console.log('error:', response.err)
                    return
                starToggle(_target)
                console.log('Star btn toggled.')


            )
        )
    )
) jQuery
