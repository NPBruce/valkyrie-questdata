mkdir build
rmdir /s/q build\D2E
rmdir /s/q build\MoM
mkdir build\D2E
mkdir build\MoM

cd source\D2E
FOR /D %%i in (*) DO (
	"C:\Program Files\7-Zip\7z.exe" a "..\..\build\D2E\%%i.valkyrie" "%%i\*" -r
	Echo Building %i.
)
cd ..\..

cd source\MoM
FOR /D %%i in (*) DO (
	"C:\Program Files\7-Zip\7z.exe" a "..\..\build\MoM\%%i.valkyrie" "%%i\*" -r
	Echo Building %i.
)
cd ..\..
