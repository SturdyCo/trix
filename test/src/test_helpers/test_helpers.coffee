helpers = Trix.TestHelpers

setFixtureHTML = (html) ->
  element = findOrCreateTrixContainer()
  element.innerHTML = html

findOrCreateTrixContainer = ->
  if container = document.getElementById("trix-container")
    container
  else
    document.body.insertAdjacentHTML("afterbegin", """<form id="trix-container"></form>""")
    document.getElementById("trix-container")

ready = null

helpers.extend
  testGroup: (name, options, callback) ->
    if callback?
      {template, setup, teardown} = options
    else
      callback = options

    beforeEach = ->
      ready = (callback) ->
        if template?
          addEventListener "trix-initialize", handler = ({target}) ->
            removeEventListener("trix-initialize", handler)
            if target.hasAttribute("autofocus")
              target.editor.setSelectedRange(0)
            callback(target)

          setFixtureHTML(JST["test_helpers/fixtures/#{template}"]())
        else
          callback()
      setup?()

    afterEach = ->
      if template?
        setFixtureHTML("")
      teardown?()

    if callback?
      QUnit.module name, (hooks) ->
        hooks.beforeEach(beforeEach)
        hooks.afterEach(afterEach)
        callback()
    else
      QUnit.module(name, {beforeEach, afterEach})

  test: (name, callback) ->
    QUnit.test name, (assert) ->
      doneAsync = assert.async()

      ready (element) ->
        done = (expectedDocumentValue) ->
          if element?
            if expectedDocumentValue
              assert.equal element.editor.getDocument().toString(), expectedDocumentValue
            requestAnimationFrame(doneAsync)
          else
            doneAsync()

        if callback.length is 0
          callback()
          done()
        else
          callback(done)
