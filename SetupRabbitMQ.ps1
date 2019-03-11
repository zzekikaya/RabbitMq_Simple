
param([String]$RabbitDllPath = "not specified")

$RabbitDllPath = Resolve-Path $RabbitDllPath 
Write-Host "Rabbit DLL Path: " 
Write-Host $RabbitDllPath -foregroundcolor green

set-ExecutionPolicy Unrestricted

$absoluteRabbitDllPath = Resolve-Path $RabbitDllPath

Write-Host "Absolute Rabbit DLL Path: " 
Write-Host $absoluteRabbitDllPath -foregroundcolor green

[Reflection.Assembly]::LoadFile($absoluteRabbitDllPath)

Write-Host "Setting up RabbitMQ Connection Factory" -foregroundcolor green
$factory = new-object RabbitMQ.Client.ConnectionFactory
$hostNameProp = [RabbitMQ.Client.ConnectionFactory].GetField(“HostName”)
$hostNameProp.SetValue($factory, “localhost”)

$usernameProp = [RabbitMQ.Client.ConnectionFactory].GetField(“UserName”)
$usernameProp.SetValue($factory, “guest”)

$passwordProp = [RabbitMQ.Client.ConnectionFactory].GetField(“Password”)
$passwordProp.SetValue($factory, “guest”)

$createConnectionMethod = [RabbitMQ.Client.ConnectionFactory].GetMethod(“CreateConnection”, [Type]::EmptyTypes)
$connection = $createConnectionMethod.Invoke($factory, “instance,public”, $null, $null, $null)

Write-Host "Setting up RabbitMQ Model" -foregroundcolor green
$model = $connection.CreateModel()

Write-Host "Creating Exchange" -foregroundcolor green
$exchangeType = [RabbitMQ.Client.ExchangeType]::Headers
$model.ExchangeDeclare("Module2.Sample6.Exchange", $exchangeType, $true)

Write-Host "Creating Server 1 Queue" -foregroundcolor green
$model.QueueDeclare(“Module2.Sample6.Queue1”, $true, $false, $false, $null)

$subscription1 = @{"material"="wood"; "customertype"="b2b";};
$model.QueueBind("Module2.Sample6.Queue1", "Module2.Sample6.Exchange", "", $subscription1)


Write-Host "Creating Server 2 Queue" -foregroundcolor green
$model.QueueDeclare(“Module2.Sample6.Queue2”, $true, $false, $false, $null)

$subscription2 = @{"material"="metal"; "customertype"="b2c";};
$model.QueueBind("Module2.Sample6.Queue2", "Module2.Sample6.Exchange", "", $subscription2)

Write-Host "Creating Server 3 Queue" -foregroundcolor green
$model.QueueDeclare(“Module2.Sample6.Queue3”, $true, $false, $false, $null)

$subscription3 = @{"x-match"="any"; "material"="wood"; "customertype"="b2b";};
$model.QueueBind("Module2.Sample6.Queue3", "Module2.Sample6.Exchange", "", $subscription3)

Write-Host "Creating Server 4 Queue" -foregroundcolor green
$model.QueueDeclare(“Module2.Sample6.Queue4”, $true, $false, $false, $null)

$subscription4 = @{"x-match"="any"; "material"="metal"; "customertype"="b2c";};
$model.QueueBind("Module2.Sample6.Queue4", "Module2.Sample6.Exchange", "", $subscription4)


Write-Host "Setup complete"