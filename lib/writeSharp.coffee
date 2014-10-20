writeSharpView = require './writeSharp-view'
path = require 'path'
fs = require 'fs'
# should the key files be hidden or not
module.exports =
  activate: (state) ->
    atom.workspaceView.command "writeSharp:loadKeys", => @loadKeys()
    atom.workspaceView.command "writeSharp:refreshKeys", => @refreshKeys()
    atom.workspaceView.command "writeSharp:checkPaths", => @checkPaths()
    atom.workspaceView.command "writeSharp:construct", => @construct()
    atom.workspaceView.command "writeSharp:switchOut", => @switchOut()
    atom.workspaceView.command "writeSharp:isDictionary", => @isDictionary()
    atom.workspaceView.command "writeSharp:newKey", => @newKey()
    atom.workspaceView.command "writeSharp:newDictionary", => @newDictionary()
    atom.workspaceView.command "writeSharp:getKeyPath", => @getKeyPath()

    atom.workspace.onDidChangeActivePaneItem(@loadKeys)

  # loadKeys is called whenever the current view is changed
  # pane is an array that contains only the active pane object
  loadKeys: (obj) ->
    pane = Object.getKeys(obj)
    pane[0]? @switchOut(pane[0].pop().getActivePaneItem().getLongTitle())

    # refreshKeys will be used only when a new key is created or an existing key
    # has its name changed
  refreshKeys: (file) ->
    parent = path.dirname(file)

    if isDictionary(path.basename(parent))
      allKeys = @checkPaths(fs.readdir(parent, readD()))
    else
      allDirs = fs.readdir(parent, readD())
      allDirs = (directory for directory in allDirs when fs.stat(dname).isDirectory() and @isDictionary(path.basename(dname)))
      allKeys = @checkPaths(allDirs)
    @construct(allKeys, file)
    @switchOut(file)

  # checkPaths is called only by @refreshKeys
  # pathNames is an array of paths to be checked
  # allKeys is the current list of keys found
  checkPaths: (pathNames, allKeys) ->
    if pathNames.length <= 0
      return allKeys

    path = pathNames.pop()
    if path.isFile()
      allKeys.push(path.getBaseName())
    else
      pathNames.push(pname) for pname in path.getEntriesSync() when pname.isFile() and isDictionary(pname.getBaseName())
    @checkPaths(pathNames, allKeys)

  # construct creates or overwrites the corresponding keyword file
  construct: (allKeys, fpath) ->
    file = @getKeyPath(fpath)
    contents = "'scopeName': 'source.writeSharp'\n
    'name': 'writeSharp'\n
    'filetypes': [\n
      'w#'\n
      'write#'\n
    ]\n
    'patterns': [\n
      'match': '("
    contents = contents + key + "|" for key in allKeys
    contents = contents + ")'\n
    'name': 'keyword'\n
  ]\n"
    fs.writeFile(file, contents, null, write())

  # switch out the grammar file for the provided keyword file
  # file is the file whose keyword file should be switched into grammar
  switchOut: (fpath) ->
    file = @getKeyPath(fpath)
    contents = fs.readFile(file, read())
    grammarPath = PackageManager.resolvePackagePath("writeSharp") + path.sep + "grammars" + path.sep + "writeSharp.cson"
    fs.writeFile(grammarPath, contents, null, write())

  # create new keyword
  newKey: ->
    # play around with using atom.open() instead
    name = prompt("Enter file name", path.dirname(atom.workspace.getActivePaneItem().getLongTitle()) + path.sep + "something.ws")
    prevFileName = atom.workspace.getActivePaneItem().getLongTitle()
    atom.workspace.open(name)
    @refreshKeys(prevFileName)

  # create new Dictionary
  newDictionary: ->
    # play around with using atom.open() instead
    name = prompt("Enter file name", path.dirname(atom.workspace.getActivePaneItem().getLongTitle() + path.sep + "new-dictionary" + path.sep))
    if isDictionary(path.basename(name)) then atom.workspace.open(name) else atom.confirm(["No -dictionary ending"])

  # convert to key path
  getKeyPath: (keyPath) ->
    ext = path.basename(keyPath)
    newExt = "." + ext.replace(".", "-") + ".keys"
    path.dirname(keyPath) + newExt

  # returns whether the directory is a dictionary
  # dname is a directory
  isDictionary: (dname) ->
    dName.search("-dictionary") > -1

  read: (err, data) ->
    if err is null then data

  #returns array of files
  readD: (err, files) ->
    if err is null then files

  write: (err) ->
    #print err if not null
