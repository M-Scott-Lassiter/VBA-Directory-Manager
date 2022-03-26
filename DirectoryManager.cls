VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "DirectoryManager"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Version 1.0.1                                                                  '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'MIT License                                                                    '
'                                                                               '
'Copyright (c) 2022 M. Scott Lassiter                                           '
'                                                                               '
'Permission is hereby granted, free of charge, to any person obtaining a copy   '
'of this software and associated documentation files (the "Software"), to deal  '
'in the Software without restriction, including without limitation the rights   '
'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      '
'copies of the Software, and to permit persons to whom the Software is          '
'furnished to do so, subject to the following conditions:                       '
'                                                                               '
'The above copyright notice and this permission notice shall be included in all '
'copies or substantial portions of the Software.                                '
'                                                                               '
'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     '
'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       '
'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    '
'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         '
'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  '
'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  '
'SOFTWARE.                                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Class Variables
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Dim FolderPath As String
Dim FolderName As String

Dim FoundFoldersList As New Collection
Dim FoundFilesList As New Collection

Dim FoundFolders As New Collection
Dim FoundFiles As New Collection

Dim isFile As Boolean
Dim OmittedPrefixValue As String

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Properties
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Public Property Get Path() As String
    Path = FolderPath
End Property
Public Property Let Path(PathName As String)
'This is the entry point to initialize the class. Trying to use any feature before running this script should abort.
    FolderPath = PathName
    If Not (Exists) Then Exit Property
    FolderPath = FormatFilePath(FolderPath)
    
    'Reinitialize if the same DirectoryManager class is set to a new path
    Set FoundFoldersList = New Collection
    Set FoundFilesList = New Collection
    Set FoundFolders = New Collection
    Set FoundFiles = New Collection
    
    FindFilesAndFolders
    FindSubFilesAndFolders
End Property


Public Property Get Name() As String
    If isFile Then
        Name = Split(FolderPath, "\")(UBound(Split(FolderPath, "\")))
    Else
        Name = Split(FolderPath, "\")(UBound(Split(FolderPath, "\")) - 1)
    End If
End Property


Public Property Get Folders() As Collection
    Set Folders = FoundFolders
End Property


Public Property Get Files() As Collection
    Set Files = FoundFiles
End Property


Public Property Get Exists() As Boolean
'Uninitialized instances of the class and folders that do not exist return false
    
    On Error Resume Next
    If Len(Dir(FolderPath, vbDirectory)) = 0 Or FolderPath = "" Or Err <> 0 Then    'Gives error 52 if file name is invalid
        Exists = False
    Else
        Exists = True
    End If
    On Error GoTo 0
    
End Property


Public Property Let OmittedPrefix(Omit As String)
'If true, the DirectoryManager ignores all files and folders that begin with the specified characters.
'   This allows the end user to setup a file structure with folders or files that he or she does not want
'   to be included when the DirectoryManager scans a path.
    OmittedPrefixValue = Omit
    Path = FolderPath   'Reinitialize the DirectoryManager, this time using the new omit prefix
End Property
Public Property Get OmittedPrefix() As String
    OmittedPrefix = OmittedPrefixValue
End Property


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Functions and Methods
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Private Sub FindFilesAndFolders()
'Loops through all files and folders in this path directory and adds them to their respective collections

    Dim RefFolders As Variant
    Dim newItem As DirectoryManager
    
    RefFolders = Dir(FolderPath, vbDirectory)
    Do While RefFolders <> "" And isFile = False
        
        'Ignore the special folders '.' and '..'
        If RefFolders <> "." And RefFolders <> ".." Then
            If UCase(Left(RefFolders, Len(OmittedPrefixValue))) <> UCase(OmittedPrefixValue) Or OmittedPrefixValue = "" Then   'Ignore the omitted prefixes, if specified
                If (GetAttr(FolderPath & RefFolders) And vbDirectory) = vbDirectory Then
                    FoundFoldersList.Add RefFolders, RefFolders
                Else
                    FoundFilesList.Add RefFolders, RefFolders
                End If
            End If
        End If
        
        RefFolders = Dir    'Required to move to the next file
    Loop
    
End Sub


Private Sub FindSubFilesAndFolders()
'After the list of folders is identified, this function recursively creates a new Folder class for each folder
'   and repeats the process.
    Dim item As Variant
    Dim newFolder As DirectoryManager
    
    
    
    For Each item In FoundFoldersList
        Set newFolder = New DirectoryManager
        newFolder.OmittedPrefix = OmittedPrefixValue
        newFolder.Path = FolderPath & item
        
        InsertCollectionValueAlphabetically FoundFolders, newFolder, newFolder.Name
    Next item
    
    For Each item In FoundFilesList
        Set newFolder = New DirectoryManager
        newFolder.OmittedPrefix = OmittedPrefixValue
        newFolder.Path = FolderPath & item

        InsertCollectionValueAlphabetically FoundFiles, newFolder, newFolder.Name
    Next item
    
End Sub


Private Sub InsertCollectionValueAlphabetically(Col As Collection, item As Variant, Key As String)
'Collections do not have a built in sort feature. This loops through each item in the collection,
'   and once the new item (key) comes later than the current loop value (Col(i).Name), then it
'   immediately exits the loop and adds the Key into that spot.

    Dim i As Long
    If Col.Count = 0 Then
        Col.Add item, Key   'First value gets added without trying to loop through
        Exit Sub
    End If
    
    For i = 1 To Col.Count
        'Convert to lower case to get predictable behavior during ASCII text comparison
        If (LCase(Key) < LCase(Col(i).Name)) Then Exit For
    Next i
    
    If i = 1 Then
        'Trying to add after index 0 results in an error
        Col.Add item, Key, 1
    Else
        Col.Add item, Key, , i - 1
    End If
End Sub


Private Function FormatFilePath(InputPath As String) As String
'If a folder, normalize the root directory file path to have a backslash at the end of it.
'   Otherwise, it is a file and should be left alone.
    FormatFilePath = InputPath
    If (GetAttr(InputPath) And vbDirectory) = vbDirectory Then
        isFile = False
        If Right(InputPath, 1) <> "\" Then FormatFilePath = InputPath & "\"
    ElseIf Len(Dir(InputPath, vbReadOnly Or vbHidden Or vbSystem Or vbDirectory)) > 0 Then
        isFile = True
    End If
    
End Function

