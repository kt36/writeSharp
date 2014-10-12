writeSharpView = require './writeSharp-view'

module.exports =
  activate: (state) ->
    atom.workspaceView.command "writeSharp:load", => @load()
    atom.workspaceView.command "writeSharp:checkPaths", => @checkPaths()
    atom.workspaceView.command "writeSharp:write", => @write()

  load: ->
    # This assumes the active pane item is an editor
    parent = File.constructor(atom.workspace.getActivePaneItem().getPath()).getParent()
    console.log("opened parent directory")

    if parent.getBaseName().search("-dictionary") > -1
      allKeys = @checkPaths(parent.getEntriesSync())
    else
      console.log("not in dictionary")
      allDirs = parent.getEntriesSync()
      allDirs = (directory for directory in allDirs when dname.isDirectory() and dName.getBaseName().search("-dictionary") > -1)
      allKeys = @checkPaths(null, allDirs)
      console.log("checked for dictionaries")
    #write allKeys into package's grammar file
    @write(allKeys)
    console.log("wrote to grammar file")

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
    grammar = File.constructor(atom.packages.resolvePackagePath("writeSharp") + "/grammars/writeSharp.cson")
    grammar.write("'name': 'writeSharp'\n
    'filetypes': [\n
      'w#'\n
      'write#'\n
    ]\n
    'patterns': [\n
      'match': '(" + key + ", " for key in allKeys + ")'\n
      'name': 'keyword'\n
    ]\n")
