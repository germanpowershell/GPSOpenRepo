<#PSScriptInfo

.VERSION 1.1.0.0

.GUID bf533bc1-76d2-4c13-a13d-1d8946c4e190

.AUTHOR Thomas Dobler - germanpowershell.com

.COMPANYNAME germanpowershell.com

.COPYRIGHT (C) 2020 by germanpowershell.com - Alle Rechte vorbehalten

.TAGS Script PowerSHELL Logon

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Aenderungsverlauf des Scripts nach dem Schema Major.Minor.Build.Revision,jeweils Major Versionen sind produktiv zu verwenden
Version     |Type      |Datum         |Benutzer            |Bemerkungen
1.0.0.0     |BUILD     |2019.01.24    |Thomas Dobler       |Script erstellt.
1.1.0.0     |MINOR     |2020.02.11    |Thomas Dobler       |Parpierkorb leeren ergänzt.


.PRIVATEDATA

#>


<# 

.DESCRIPTION 
 LogonScript für sämtliche Windows Versionen mit den wichtigsten Befehlen bei jedem Logon 

#> 
Param()

$AufbewahrungTage = "7"

# Speichert die momentanen Dateien auf dem Desktop vom Benutzer und vom Public-Benutzer
$IconSnapshot = (Get-ChildItem "$env:USERPROFILE\Desktop","$env:SystemDrive\Users\Public\Desktop").FullName

# Update aller Software die mit Chocolatey installiert wurde
Invoke-Expression -Command "choco upgrade all -y --acceptlicense --ignore-checksums"

# Holt und installiert alle zur Verfügung gestellten Windows Updates
Install-Module pswindowsupdate -Force -Confirm:$false -ErrorAction SilentlyContinue
Get-WUInstall -AcceptAll -Install -IgnoreReboot -ErrorAction SilentlyContinue

# Aktualisiert die Hilfe Dateien von PowerSHELL
Update-Help -Force -ErrorAction SilentlyContinue

# Aktualisiert alle installierten PowerSHELL Module
Get-InstalledModule | Update-Module -ErrorAction SilentlyContinue

# Löscht alle neuen Verknüpfungen, die vor dem Update noch nicht auf dem Desktop waren
(Get-ChildItem "$env:USERPROFILE\Desktop","$env:SystemDrive\Users\Public\Desktop").FullName | ? {$_ -notin $IconSnapshot} | Remove-Item -Force

# Defender Einstellungen
# Chrome Browser Schutz installieren                                    
choco install windows-defender-browser-protection-chrome -y --acceptlicense                                   
            
# Werbung Blockieren für Internet Explorer/Edge, Chrome und Firefox            
# choco install adblockplusie, adblockpluschrome, adblockplus-firefox -y            
                                    
# Email Scanning einschalten                                    
Set-MpPreference -DisableEmailScanning:$false                                    
                                    
# USB Laufwerke scannen                                    
Set-MpPreference -DisableRemovableDriveScanning:$false                                    
                                    
# Netzwerkschutz einschalten                                    
Set-MpPreference -EnableNetworkProtection Enabled                                    
                                    
# Immer Scannen auch wenn der Computer verwendet wird                                    
Set-MpPreference -ScanOnlyIfIdleEnabled:$false                                    
                                    
# Cloud Schutz immer verwenden                                    
Set-MpPreference -SubmitSamplesConsent SendAllSamples                                     
                       
# Defender in die Sandbox zwingen                        
[Environment]::SetEnvironmentVariable("MP_FORCE_USE_SANDBOX",1,"Machine")                        
                        
# Registry neu Laden                        
RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True

# Defender Regeln zur Reduktion von Oberflächenattacken            
# Falls du unsicher bist, lasse alle Regeln aktiv            
            
$RegelID = @()            
            
# Blockiere alle Office Programme Unterprozesse zu erstellen            
$RegelID += "D4F940AB-401B-4EFC-AADC-AD5F3C50688A"            
            
# Verhindere die Ausführung von potenziell verschleierten Scripts            
$RegelID += "5BEB7EFE-FD9A-4556-801D-275E5FFC04CC"            
            
# Blockiere Office Makros Win32 API Aufrufe zu tätigen            
$RegelID += "92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B"            
            
# Blockiere Office Programme vom Erstellen von ausführbarem Inhalt            
$RegelID += "3B576869-A4EC-4529-8536-B80A7769E899"            
            
# Verhindert die Infizierung von anderen Prozessen durch Office Programme            
$RegelID += "75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84"            
            
# Verhindert den Download ausführbaren Codes durch JavaScript und VBScript            
$RegelID += "D3E037E1-3EB8-44C8-A917-57927947596D"            
            
# Blockiert ausführbare Programme von Email Programmen und Webmail            
$RegelID += "BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550"            
            
# Verhindere ausführbare, unvertrauenswürdige Dateien             
$RegelID += "01443614-cd74-433a-b99e-2ecdc07bfc25"            
            
# Erweiterter Schutz vor Ransomware            
$RegelID += "c1db55ab-c21a-4637-bb3f-a12568109d35"            
            
# Verhindere den Diebstahl von Windows-Anmeldedaten (Credentials)            
$RegelID += "9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2"            
            
# Verhindere die Erstellung von Prozessen durch PowerShell und WMI Befehlen            
$RegelID += "d1e49aac-8f56-4280-b9ba-993a6d77406c"            
            
# Verhindere die Ausführung von unsignierten und nicht vertrauenswürdigen Programmen von USB            
$RegelID += "b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4"            
            
# Blockiere Office Kommunikations-Programme vom erstellen von Unterprozessen            
$RegelID += "26190899 - 1602 - 49e8 - 8b27-eb1d0a1ce869"            
            
# Blockiere Adobe Reader vom erstellen von Unterprozessen            
$RegelID += "7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c"            
            
# Verhindere WMI Event Abonnemente            
$RegelID += "e6db77e5-3df2-4cf1-b95a-636979351e5b"            
            
foreach ($Regel in $RegelID)             
    {            
        # Aktivieren der definierten Regeln            
        Add-MpPreference -AttackSurfaceReductionRules_Ids $Regel -AttackSurfaceReductionRules_Actions Enabled            
    }

# Defender Signaturen aktualisieren
Update-MpSignature

# Fullscan starten
Start-MpScan -ScanType FullScan

# Papierkorb nach Anzahl Tagen leeren
if ($AufbewahrungTage -ne "")
    {
        $Shell = New-Object -ComObject Shell.Application # Objekt für die Shell erstellen
        $Recycler = $Shell.NameSpace(0xa) # Papierkorb aus der Shell mounten
        foreach($item in $Recycler.Items()) # Jedes Element des Parpierkorbs anschauen
        {
            $DeletedDate = $Recycler.GetDetailsOf($item,2) -replace "\u200f|\u200e","" # Datum extrahieren und unsichtbare Unicode Zeichen entfernen
            $DeletedDatetime = Get-Date $DeletedDate # String von Datum und Uhrzeit in Zeitobjekt umwandeln
            [Int]$DeletedDays = (New-TimeSpan -Start $DeletedDatetime -End $(Get-Date)).Days # Gelöschte Tage berechnen
            If($DeletedDays -ge $AufbewahrungTage) # Falls Objekt älter als Aufbewahrung
                {
                    Remove-Item -Path $item.Path -Confirm:$false -Force -Recurse -ErrorAction SilentlyContinue # Objekte rekursiv Löschen
                }
        }
    }
