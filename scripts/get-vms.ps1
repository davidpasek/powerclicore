Connect-VIServer -Server vc01.home.uw.cz -User admin -Password VMw@reC4C. | Out-Null

Get-VM | Select-Object -ExpandProperty Name

