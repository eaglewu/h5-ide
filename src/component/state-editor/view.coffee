StateEditorView = Backbone.View.extend({

	el: '#state-editor'

	model: new StateEditorModel()

	editorHTML: $('#state-template-main').html()
	paraListHTML: $('#state-template-para-list').html()
	paraDictItemHTML: $('#state-template-para-dict-item').html()
	paraArrayItemHTML: $('#state-template-para-array-item').html()

	events:

		# 'AUTOCOMPLETE_SELECTED .autocomplete-input': 'onAutoCompleteSelected'
		'keyup .parameter-item.dict .parameter-value': 'onDictInputChange'
		'blur .parameter-item.dict .parameter-value': 'onDictInputBlur'

		'keyup .parameter-item.array .parameter-value': 'onArrayInputChange'
		'blur .parameter-item.array .parameter-value': 'onArrayInputBlur'

	initialize: () ->

		this.compileTpl()
		this.render()

	render: () ->

		this.refreshStateList()

	compileTpl: () ->

		this.editorTpl = Handlebars.compile(this.editorHTML)

		Handlebars.registerPartial('state-template-para-list', this.paraListHTML)
		Handlebars.registerPartial('state-template-para-dict-item', this.paraDictItemHTML)
		Handlebars.registerPartial('state-template-para-array-item', this.paraArrayItemHTML)

		this.paraListTpl = Handlebars.compile(this.paraListHTML)
		this.paraDictListTpl = Handlebars.compile(this.paraDictItemHTML)
		this.paraArrayListTpl = Handlebars.compile(this.paraArrayItemHTML)

	refreshStateList: () ->

		that = this

		cmdName = 'apt pkg'
		cmdParaMap = that.model.get('cmdParaMap')
		cmdParaAry = cmdParaMap[cmdName]

		stateListObj = {
			state_list: [{
				cmd_name: cmdName,
				parameter_list: cmdParaAry
			}]
		}

		that.$el.html(this.editorTpl(stateListObj))

		that.bindCommandEvent()

	refreshParaList: (cmdName) ->

		that = this

		if not cmdName
			$('.parameter-list').html('')
			return

		cmdParaMap = that.model.get('cmdParaMap')
		cmdParaAry = cmdParaMap[cmdName]

		$('.parameter-list').html(that.paraListTpl({
			parameter_list: cmdParaAry
		}))

		that.bindParaListEvent(cmdName)

	bindCommandEvent: () ->

		that = this

		cmdParaMap = that.model.get('cmdParaMap')
		cmdNameAry = _.keys(cmdParaMap)

		cmdNameAry = $.map(cmdNameAry, (value, i) ->
			return {'name': value}
		)

		$cmdValueInput = $('.editable-area.command-value')
		$cmdValueInput.atwho({
			at: '',
			tpl: '<li data-value="${atwho-at}${name}">${name}</li>'
			data: cmdNameAry,
			onSelected: (value) ->
				$cmdValueInput.attr('data-value', value)
				that.refreshParaList(value)
		})

		that.refreshParaList()

	bindParaListEvent: (cmdName) ->

		that = this

		cmdParaMap = that.model.get('cmdParaMap')
		atValueAry = cmdParaMap[cmdName]

		$('.parameter-list .editable-area.line, .editable-area.text').atwho({
			at: '@',
			tpl: '<li data-value="${atwho-at}${name}">${name}</li>'
			data: atValueAry
		})

	bindDictInputEvent: ($dictItem) ->

		that = this
		cmdName = that.getCurrentCommand($dictItem)

		cmdParaMap = that.model.get('cmdParaMap')
		atValueAry = cmdParaMap[cmdName]

		$paraInputElem = $dictItem.find('.parameter-value')
		$paraInputElem.atwho({
			at: '@',
			tpl: '<li data-value="${atwho-at}${name}">${name}</li>'
			data: atValueAry
		})

	bindArrayInputEvent: ($arrayItem) ->

		that = this
		cmdName = that.getCurrentCommand($arrayItem)

		cmdParaMap = that.model.get('cmdParaMap')
		atValueAry = cmdParaMap[cmdName]

		$paraInputElem = $arrayItem.find('.parameter-value')
		$paraInputElem.atwho({
			at: '@',
			tpl: '<li data-value="${atwho-at}${name}">${name}</li>'
			data: atValueAry
		})

	onDictInputChange: (event) ->

		that = this

		$currentInputElem = $(event.currentTarget)
		$currentDictItemElem = $currentInputElem.parents('.parameter-dict-item')
		nextDictItemElemAry = $currentDictItemElem.next()

		# append new dict item
		if not nextDictItemElemAry.length

			$currentDictItemContainer = $currentDictItemElem.parents('.parameter-container')

			prevInputAry = $currentInputElem.prev()
			nextInputAry = $currentInputElem.next()

			$leftInputElem = null
			$rightInputElem = null
			if nextInputAry.length
				$leftInputElem = $currentInputElem
				$rightInputElem = $(nextInputAry[0])
			else if prevInputAry.length
				$leftInputElem = $(prevInputAry[0])
				$rightInputElem = $currentInputElem

			leftInputValue = $leftInputElem.text()
			rightInputValue = $rightInputElem.text()

			if leftInputValue or rightInputValue
				newDictItemHTML = that.paraDictListTpl({})
				$currentDictItemContainer.append(newDictItemHTML)
				# $newDictItem = $($.parseHTML(newDictItemHTML)).appendTo($currentDictItemContainer)
				that.bindDictInputEvent($currentDictItemContainer)

	onDictInputBlur: (event) ->

		$currentInputElem = $(event.currentTarget)
		$currentDictItemContainer = $currentInputElem.parents('.parameter-container')
		allInputElemAry = $currentDictItemContainer.find('.parameter-dict-item')
		_.each allInputElemAry, (itemElem, idx) ->
			inputElemAry = $(itemElem).find('.parameter-value')
			isAllInputEmpty = true
			_.each inputElemAry, (inputElem) ->
				if $(inputElem).text()
					isAllInputEmpty = false
				null
			if isAllInputEmpty and idx isnt allInputElemAry.length - 1
				$(itemElem).remove()
			null

	onArrayInputChange: (event) ->

		that = this

		$currentInputElem = $(event.currentTarget)
		nextInputElemAry = $currentInputElem.next()

		# append new dict item
		if not nextInputElemAry.length

			$currentArrayInputContainer = $currentInputElem.parents('.parameter-container')

			currentInput = $currentInputElem.text()

			if currentInput
				newArrayItemHTML = that.paraArrayListTpl({})
				$currentArrayInputContainer.append(newArrayItemHTML)
				that.bindArrayInputEvent($currentArrayInputContainer)

	onArrayInputBlur: (event) ->

		$currentInputElem = $(event.currentTarget)
		$currentArrayItemContainer = $currentInputElem.parents('.parameter-container')
		allInputElemAry = $currentArrayItemContainer.find('.parameter-value')
		_.each allInputElemAry, (itemElem, idx) ->
			inputValue = $(itemElem).text()
			if not inputValue and idx isnt allInputElemAry.length - 1
				$(itemElem).remove()
			null

	getCurrentCommand: ($subElem) ->

		$stateItem = $subElem.parents('.state-item')
		$cmdValue = $stateItem.find('.command-value')
		return $cmdValue.text()

})

window.StateEditorView = StateEditorView