{View} = require 'atom'

module.exports =
class Write#View extends View
  @content: ->
    @div class: 'write# overlay from-top', =>
      @div "The Write# package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "write#:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "Write#View was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
