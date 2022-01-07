Add-Type -AssemblyName PresentationFramework

$xamlFile="C:\Users\fearr\Desktop\MultipleForms\MainWindow1.xaml"
$inputXAML=Get-Content -Path $xamlFile -Raw
$inputXAML=$inputXAML -replace 'mc:Ignorable="d"','' -replace "x:N","N" -replace '^<Win.*','<Window'
[XML]$XAML=$inputXAML

$reader = New-Object System.Xml.XmlNodeReader $XAML
try{
    $form1=[Windows.Markup.XamlReader]::Load($reader)
}catch{
    Write-Host $_.Exception
    throw
}

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    try{
        Set-Variable -Name "var_$($_.Name)" -Value $form1.FindName($_.Name) -ErrorAction Stop
    }catch{
        throw
    }
}

Get-Service | ForEach-Object {$var_form1_ddlService.items.Add($_.Name)}

$var_form1_btnGetDetails.Add_Click({
    $xamlFile="C:\Users\fearr\Desktop\MultipleForms\MainWindow2.xaml"
    $inputXAML=Get-Content -Path $xamlFile -Raw
    $inputXAML=$inputXAML -replace 'mc:Ignorable="d"','' -replace "x:N","N" -replace '^<Win.*','<Window'
    [XML]$XAML=$inputXAML

    $reader = New-Object System.Xml.XmlNodeReader $XAML
    try{
        $form2=[Windows.Markup.XamlReader]::Load($reader)
    }catch{
        Write-Host $_.Exception
        throw
    }

    $xaml.SelectNodes("//*[@Name]") | ForEach-Object {
        try{
            Set-Variable -Name "var_$($_.Name)" -Value $form2.FindName($_.Name) -ErrorAction Stop
        }catch{
            throw
        }
    }

    $ServiceName=$var_form1_ddlService.SelectedItem
    $var_form2_lblservicename.Content=$ServiceName
    $var_form2_lblservicestatus.Content=$(Get-Service $ServiceName | Select-Object status).status

    $var_form2_btnStart.Add_Click({
        Get-Service $ServiceName | Start-Service
        $var_form2_lblservicestatus.Content=$(Get-Service $ServiceName | Select-Object status).status
    })

    $var_form2_btnStop.Add_Click({
        Get-Service $ServiceName | Stop-Service
        $var_form2_lblservicestatus.Content=$(Get-Service $ServiceName | Select-Object status).status
    })

    $var_form2_btnRestart.Add_Click({
        Get-Service $ServiceName | Restart-Service
        $var_form2_lblservicestatus.Content=$(Get-Service $ServiceName | Select-Object status).status
    })

    $var_form2_btnClose.Add_Click({
        $form2.close()
    })

    $form2.showDialog()
})


$form1.ShowDialog()

$form1.Close()
$form2.close()