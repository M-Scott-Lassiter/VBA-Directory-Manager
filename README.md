# Excel-VBA-Directory-Manager
Uses a single Class to parse all the files and folders in a specified directory without using FileSystemObject or setting special references. Perfect for integrating into projects you can distribute to the lay person without worrying if they have set their references correctly in the VBA editor.

## Requirements
- Microsoft Office 2007 or newer (Not tested for earlier versions)
- A macro enabled file
- Knowledge of how to [add a Class module](https://analystcave.com/vba-vba-class-tutorial/) to your project 

## Getting Started
A single Class file contains all functionality. To use it in your project, use one of the following methods to add them in the IDE:

To use it in your project, then use one of the following methods to add them in the IDE.

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

The below examples are also located in the [example workbook](/ExampleWorkbook.xlsm).

## Initial Setup, Printing All Files/Folders

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
Changing `OmittedPrefix` will cause the DirectoryManager to re-parse the file or folder set at the current `Path`.

## Check if a File or Folder Exists

The DirectoryManager can easily tell you if a file or folder at the specified `Path` exists.

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


# License
Distributed under the MIT License. See [LICENSE](./LICENSE) for more information.


# Contact
Reach me on [LinkedIn](https://www.linkedin.com/in/mscottlassiter/) or [Twitter](https://twitter.com/MScottLassiter).