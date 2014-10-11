Write#View = require './write#-view'

module.exports =
  activate: (state) ->
    atom.workspaceView.command "Write#:load", => @load()
    atom.workspaceView.command "Write#:checkPaths", => @checkPaths()
    atom.workspaceView.command "Write#:write", => @write()

  load: ->
    # This assumes the active pane item is an editor
    parent = File.constructor(atom.workspace.getActivePaneItem().getPath()).getParent()

    if parent.getBaseName().search("-dictionary") > -1
      allKeys = @checkPaths(parent.getEntriesSync())
    else
      allDirs = parent.getEntriesSync()
      allDirs = (directory for directory in allDirs when dname.isDirectory() and dName.getBaseName().search("-dictionary") > -1)
      allKeys = @checkPaths(null, allDirs)
    #write allKeys into package's grammar file
    @write(allKeys)

  checkPaths: (error, pathNames, allKeys) ->
    if error isnt null
      #show error to user
      return

    if pathNames.length <= 0
      return allKeys

    path = pathNames.pop()
    if path.isFile()
      allKeys.push(path.getBaseName())
    else
      pathNames.push(pname) for pname in path
    @checkPaths(null, pathNames, allKeys)

  write: (allKeys) ->
    grammar = File.constructor(atom.packages.resolvePackagePath("Write#") + "/grammars/write#.cson")
    grammar.write("'name': 'Write#'\n
    'filetypes': [\n
      'w#'\n
      'write#'\n
    ]\n
    'patterns': [\n
      'match': '(" + key + ", " for key in allKeys + ")'\n
      'name': 'keyword'\n
    ]\n")
