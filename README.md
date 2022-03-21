# VBA Directory Manager
Easily check whether files or folders exist, and parse all the files and folders in a directory.

DirectoryManager runs on all macro-enabled Microsoft Office products and uses a VBA Class script only without using FileSystemObject or setting special references. Therefore, it is perfect for integrating into projects you will distribute to a lay person without worrying if they have set their references correctly in the VBA editor.

This Class does not provide direct support for moving, copying, or deleting files, but accomplishing these tasks is straight forward using built in VBA methods.


## Requirements
- Microsoft Office 2007 or newer (Not tested for earlier versions)
- A macro enabled file


## Getting Started
A single Class file contains all functionality. To use it in your project, use one of the following methods to add them in the IDE:

- Save the [source code module](/DirectoryManager.cls) to your machine, then import it into the Project using the IDE

Or,

- Create a blank class module in your project, name it `DirectoryManager`, and then copy/paste the [source code](/DirectoryManager.cls).


# Class Properties

| Property      	| Type                   	| Description                                                                                                                                                                                                                                                                                      	|
|---------------	|------------------------	|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| Exists        	| Boolean (Read Only)    	| For both files and folders, returns `True` if the `Path` exists and is not an empty string.                                                                                                                                                                                                      	|
| Files         	| Collection (Read Only) 	| Returns an Excel Collection object. Each item inside contains another instance of DirectoryManager for the applicable file.                                                                                                                                                                      	|
| Folders       	| Collection (Read Only) 	| Returns an Excel Collection object. Each item inside contains another instance of DirectoryManager for the applicable folder.                                                                                                                                                                    	|
| Name          	| String (Read Only)     	| Returns the name of the file or folder.                                                                                                                                                                                                                                                          	|
| OmittedPrefix 	| String (Read/Write)    	| Defaults to an empty string. If set, this will omit all files and folders that start with the `OmittedPrefix` string during the file parsing process. Changing this value will cause the `DirectoryManager` instance to recalculate. This value passes down to all files and folders beneath it. 	|
| Path          	| String (Read/Write)    	| Returns the full system path of the file or folder.                                                                                                                                                                                                                                              	|



# Example Use
DirectoryManager is simple and fast to set up. The below examples will walk you through common use. They are also located in the [example workbook](/ExampleWorkbook.xlsm).


## Initial Setup, List All Files and Folders in a Custom Directory

The first step is to declare the variable and initialize it with a path. The path can be to either a folder or a file.

If set to a folder, DirectoryManager then parses all the files, folders, and subfolders in that location. These are stored and accessed in Collections.


```VBA
Sub CreateNewDirectoryManager()

    Dim dm As DirectoryManager
    Dim item As Variant
    
    Set dm = New DirectoryManager
    dm.Path = ThisWorkbook.Path & "\Sample Data Set"
    
    'Print a list of all folders:
    Debug.Print "Folders: " & dm.Folders.Count
    For Each item In dm.Folders
        Debug.Print item.Name
    Next item
    
    'Print a list of all files:
    Debug.Print "Files: " & dm.Files.Count
    For Each item In dm.Files
        Debug.Print item.Name
    Next item
    
    'Output from above:
    
'    Folders: 5
'    _My Personal Documents
'    Contacts
'    Documents
'    My Publications
'    Pictures
'    Files: 4
'    _Sample File A.txt
'    Sample File 1.txt
'    Sample File 2.txt
'    Sample File 3.txt

End Sub
```

## Use Omitted Characters to Exclude Files or Folders
Setting the `OmittedPrefix` property to a non-empty string will cause the DirectoryManager to exclude any file or folder that starts with that string.

This is useful if you want to use DirectoryManager to exclude specific folders or files from your project.

```VBA
Sub SetOmmitedPrefix()

    Dim dm As DirectoryManager
    Dim item As Variant
    
    Set dm = New DirectoryManager
    dm.OmittedPrefix = "_"
    dm.Path = ThisWorkbook.Path & "\Sample Data Set"
    
    'Print a list of all folders:
    Debug.Print "Folders: " & dm.Folders.Count
    For Each item In dm.Folders
        Debug.Print item.Name
    Next item
    
    'Print a list of all files:
    Debug.Print "Files: " & dm.Files.Count
    For Each item In dm.Files
        Debug.Print item.Name
    Next item
    
    'Output from above:
    
'    Folders: 4
'    Contacts
'    Documents
'    My Publications
'    Pictures
'    Files: 3
'    Sample File 1.txt
'    Sample File 2.txt
'    Sample File 3.txt

End Sub
```
Changing `OmittedPrefix` at any time will cause the DirectoryManager to re-parse the file or folder set at the current `Path`.


## Check if a File or Folder Exists
The DirectoryManager can tell you if a file or folder at the specified `Path` exists.

```VBA
Sub CheckIfFileOrFolderExists()

    Dim dm As DirectoryManager
    
    'Folders
    Set dm = New DirectoryManager
    dm.Path = ThisWorkbook.Path & "\Sample Data Set\Contacts"
    
    Debug.Print dm.Exists   'True
    
    dm.Path = ThisWorkbook.Path & "\Sample Data Set\Folder That Doesn't Exist"
    Debug.Print dm.Exists   'False
    
    
    'Files
    dm.Path = ThisWorkbook.Path & "\Sample Data Set\Contacts\My Phone.txt"
    Debug.Print dm.Exists   'True
    
    dm.Path = ThisWorkbook.Path & "\Sample Data Set\Contacts\A File That Doesn't Exist.txt"
    Debug.Print dm.Exists   'False

End Sub
```


## Print a List of All Folders and Files
Using a helper method, we can recursively iterate through every file and folder in the DirectoryManager. This example prints the results to the Immediate Window.

```VBA
Sub PrintFilesAndFolders(Directory As DirectoryManager, Optional indent As String)
'Helper method

    Dim folder As DirectoryManager
    Dim file As DirectoryManager
    Dim newIndent As String
    
    For Each folder In Directory.Folders
        Debug.Print indent & "+ " & folder.Name
        newIndent = indent & "  "
        PrintFilesAndFolders folder, newIndent
    Next folder
    
    For Each file In Directory.Files
        Debug.Print indent & "- " & file.Name
    Next file
    
End Sub

Sub LoopThroughAllFilesAndFolders()

    Dim dm As DirectoryManager
    
    Set dm = New DirectoryManager
    dm.Path = ThisWorkbook.Path & "\Sample Data Set"
    
    PrintFilesAndFolders dm
    
    'Output from above:
    
'    + _My Personal Documents
'      - Document 1.txt
'      - Document 2.txt
'      - Document 3.txt
'    + Contacts
'      + _Emergency Contacts
'        - Father.txt
'        - Mother.txt
'        - Sibling.txt
'        - Spouse.txt
'      + _Personal Contacts
'        - Contact 1.txt
'        - Contact 2.txt
'        - Contact 3.txt
'      + Business Contacts
'        - _Contact 1A.txt
'        - _Contact 2A.txt
'        - Contact 1.txt
'        - Contact 2.txt
'        - Contact 3.txt
'        - Contact 4.txt
'        - Contact 5.txt
'        - Contact 6.txt
'        - Contact 7.txt
'      - _My Old Phone.txt
'      - My Phone.txt
'    + Documents
'      - Document 1.txt
'      - Document 2.txt
'      - Document 3.txt
'      - Document 4.txt
'      - Document 5.txt
'      - Document 6.txt
'    + My Publications
'      - Publication 1.txt
'      - Publication 2.txt
'      - Publication 3.txt
'      - Publication 4.txt
'      - Publication 5.txt
'    + Pictures
'    - _Sample File A.txt
'    - Sample File 1.txt
'    - Sample File 2.txt
'    - Sample File 3.txt
    
End Sub
```


# Contributing and Outlook
I am not actively pursuing additional development. This Class resource has all intended functionality in version 1.0. I consider it feature complete, but will continue to provide bug support.

That said, I will in no way turn away additional contributions or expansions if beneficial or needed in the future.

All are welcome to open an issue or feature request.


# License
Distributed under the [MIT License](./LICENSE), copyright 2022.


# Contact
Reach me on [LinkedIn](https://www.linkedin.com/in/mscottlassiter/) or [Twitter](https://twitter.com/MScottLassiter).