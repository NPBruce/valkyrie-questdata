Set objShell = WScript.CreateObject("WScript.Shell")
Set objFS=CreateObject("Scripting.FileSystemObject")

Build("D2E")
Build("MoM")

Sub Build(gameType)

    Dim versions
    Set versions = CreateObject _
    ("Scripting.Dictionary")
    Wscript.Echo "Reading Manifest: build/" + gameType + "/manifest.ini"
    Set manFile = objFS.GetFile("build/" + gameType + "/manifest.ini")
    Set manData = manFile.OpenAsTextStream
    strPackage = ""
    Do Until manData.AtEndOfStream
        strLine = manData.ReadLine
        If StrComp(Left(strLine, 1),"[") = 0 Then
            strPackage = Mid(strLine, 2, Len(strLine) - 2)
            Wscript.Echo strPackage
        End If
        If StrComp(Left(strLine, 8),"version=") = 0 Then
            Wscript.Echo "Package: " + strPackage + " Version: " + Right(strLine, Len(strLine) - 8)
            versions.Add strPackage, Right(strLine, Len(strLine) - 8)
        End If
    Loop
    manData.Close
    Wscript.Echo ""

    Set manData = manFile.OpenAsTextStream(2)
    For Each d In objFS.GetFolder("source/" + gameType).SubFolders
        packageName = d.Name
        iniLoc = d.Path & "/quest.ini"
        outLoc = "build/" + gameType + "/" + packageName + ".valkyrie"
        version = 0
        Wscript.Echo "Found Dir: " + d.Path
        if versions.Exists(packageName) Then
            version = versions.Item(packageName)
        End If

        If objFS.FileExists(iniLoc) Then
            Set fileIni = objFS.GetFile(iniLoc)
            If objFS.FileExists(outLoc) Then
                Set fileOut = objFS.GetFile(outLoc)
                If fileIni.DateLastModified > fileOut.DateLastModified Then
                    version = version + 1
                End If
            End If

            manData.Write "[" + packageName + "]" + vbCrLf
            manData.Write "version=" & version & vbCrLf

            Set iniData = fileIni.OpenAsTextStream
            inQuest = false
            Do Until iniData.AtEndOfStream
                strLine = iniData.ReadLine

                If StrComp(Left(strLine, 1),"[") = 0 Then
                    inQuest = false
                End If

                If inQuest Then
                    manData.Write strLine & vbCrLf
                End If

                If StrComp(Left(strLine, 7),"[Quest]") = 0 Then
                    inQuest = true
                End If
            Loop
            manData.Write vbCrLf
        End If
    Next
    manData.Close

    If objFS.FileExists("build" + gameType + "/*.valkyrie") Then
        objFS.DeleteFile("build" + gameType + "/*.valkyrie")
    End If

    For Each d In objFS.GetFolder("source/" + gameType).SubFolders
        outLoc = "build/" + gameType + "/" + d.Name + ".valkyrie"
        cmd = """C:\Program Files\7-Zip\7z.exe"" a -tzip """ & outLoc & """ """ & d.Path & "\*"" -r"
        objShell.Run(cmd)
    Next
    manData.Close
End Sub
