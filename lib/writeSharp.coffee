writeSharpView = require './writeSharp-view'

module.exports =
  activate: (state) ->
    atom.workspaceView.command "writeSharp:loadKeys", => @loadKeys()
    atom.workspaceView.command "writeSharp:refreshKeys", => @refreshKeys()
    atom.workspaceView.command "writeSharp:checkPaths", => @checkPaths()
    atom.workspaceView.command "writeSharp:construct", => @construct()
    atom.workspaceView.command "writeSharp:switchOut", => @switchOut()
    atom.workspaceView.command "writeSharp:isDictionary", => @isDictionary()

    atom.workspace.observeActivePaneItem(@loadKeys)

  # loadKeys is called whenever the current view is changed
  # pane is an array that contains only the active pane object
  loadKeys: (obj) ->
    pane = Object.keys(obj)
    curFile = pane[0]?.buffer.file
    @switchOut(curFile)


    # refreshKeys will be used only when a new key is created or an existing key
    # has its name changed
  refreshKeys: (file) ->
    parent = file.getParent()
    console.log("opened parent directory")

    if dname.isDirectory() and isDictionary(parent)
      console.log("in dictionary")
      allKeys = @checkPaths(parent.getEntriesSync())
    else
      console.log("not in dictionary")
      allDirs = parent.getEntriesSync()
      allDirs = (directory for directory in allDirs when dname.isDirectory() and @isDictionary(dname)
      allKeys = @checkPaths(allDirs)
      console.log("checked all dictionaries")

    @construct(allKeys, file.getBaseName())
    console.log("wrote to keyword file")

  # checkPaths is called only by @refreshKeys
  checkPaths: (pathNames, allKeys) ->
    if pathNames.length <= 0
      return allKeys

    path = pathNames.pop()
    if path.isFile()
      allKeys.push(path.getBaseName())
    else
      pathNames.push(pname) for pname in path.getEntriesSync() when pname.isFile() and pName.getBaseName().search("-dictionary") > -1
    @checkPaths(pathNames, allKeys)

  # construct creates or overwrites the corresponding keyword file
  construct: (allKeys, fname) ->
    # write hidden keyword file
    fname.replace(".", "-")
    File.constructor("." + fname + ".keys")

  # switch out the grammar file for the provided keyword file
  # file is the file whose keyword file should be switched into grammar
  switchOut: (file) ->
    # direct read is required
    contents = file.read(true)
    grammarPath = PackageManager.resolvePackagePath("writeSharp") + "/grammars/writeSharp.cson"
    File.constructor(grammarPath).write(contents)

  # create new keyword
  newKey: ->
    # play around with using atom.open() instead
    name = prompt("Enter file name", atom.workspace.getActivePaneItem?.buffer.file.getPath() + "/something.ws")
    prevFile = atom.workspace.getActivePaneItem()?.buffer.file
    atom.workspace.open(name)
    @refreshKeys(prevFile)

  # create new Dictionary
  newDictionary: ->
    # play around with using atom.open() instead
    name = prompt("Enter file name", atom.workspace.getActivePaneItem?.buffer.file.getPath() + "/new-dictionary/")
    if isDictionary(name)? atom.workspace.open(name) : atom.confirm(["No -dictionary ending"])

  # returns whether the directory is a dictionary
  # dname is a directory
  isDictionary: (dname) ->
    dName.getBaseName().search("-dictionary") > -1
