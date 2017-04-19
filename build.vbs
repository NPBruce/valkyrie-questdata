Set objShell = WScript.CreateObject("WScript.Shell")
Set objFS=CreateObject("Scripting.FileSystemObject")

Build("D2E")
Build("MoM")

Sub Build(gameType)

    If objFS.FileExists("../valkyrie-store/" + gameType + "/*.valkyrie") Then
        objFS.DeleteFile("../valkyrie-store/" + gameType + "/*.valkyrie")
    End If

    Set manFile = objFS.GetFile("../valkyrie-store/" + gameType + "/manifest.ini")
    Set manData = manFile.OpenAsTextStream(2)
    Set dictFile = objFS.GetFile("../valkyrie-store/" + gameType + "/Localization.txt")
    Set dictData = dictFile.OpenAsTextStream(2)
    dictData.Write ".,English,Spanish,French,German,Italian,Portuguese,Polish,Japanese,Chinese" + vbCrLf

    For Each d In objFS.GetFolder("source/" + gameType).SubFolders
        packageName = d.Name
        iniLoc = d.Path & "/quest.ini"
        dictLoc = d.Path & "/Localization.txt"
        outLoc = "../valkyrie-store/" + gameType + "/" + packageName + ".valkyrie"

        Wscript.Echo "Found Dir: " + d.Path

        cmd = """C:\Program Files\7-Zip\7z.exe"" a -tzip """ & outLoc & """ """ & d.Path & "\*"" -r"
        objShell.Run cmd, 1, true

        If objFS.FileExists(iniLoc) Then
            Set fileIni = objFS.GetFile(iniLoc)
            manData.Write "[" + packageName + "]" + vbCrLf

            cmd = "certutil -hashfile " + outLoc + " sha256"
            Set aRet = objShell.Exec(cmd)
            aRet.StdOut.ReadLine()
            manData.Write "version=" + aRet.StdOut.ReadLine() + vbCrLf

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
        If objFS.FileExists(dictLoc) Then
            Set fileDict = objFS.GetFile(dictLoc)
            Set qDictData = fileDict.OpenAsTextStream
            inQuest = false
            Do Until qDictData.AtEndOfStream
                strLine = qDictData.ReadLine
                If StrComp(Left(strLine, 10),"quest.name") = 0 Then
                    dictData.Write packageName + Right(strLine, Len(strLine) - 5) + vbCrLf
                End If
            Loop
        End If
    Next
    manData.Close
    dictData.Close
End Sub
