<#
MindMiner  Copyright (C) 2018  Oleg Samsonov aka Quake4
https://github.com/Quake4/MindMiner
License GPL-3.0
#>

if ([Config]::ActiveTypes -notcontains [eMinerType]::nVidia -and [Config]::ActiveTypes -notcontains [eMinerType]::AMD) { exit }
if (![Config]::Is64Bit) { exit }

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Cfg = [BaseConfig]::ReadOrCreate([IO.Path]::Combine($PSScriptRoot, $Name + [BaseConfig]::Filename), @{
	Enabled = $true
	BenchmarkSeconds = 60
	ExtraArgs = $null
	Algorithms = @(
		[AlgoInfoEx]@{ Enabled = $true; Algorithm = "equihash144" }
		[AlgoInfoEx]@{ Enabled = $true; Algorithm = "equihash192" }
		[AlgoInfoEx]@{ Enabled = $true; Algorithm = "equihash96" }
		[AlgoInfoEx]@{ Enabled = $true; Algorithm = "equihashBTG" }
)})

if (!$Cfg.Enabled) { return }

$Cfg.Algorithms | ForEach-Object {
	if ($_.Enabled) {
		$Algo = Get-Algo($_.Algorithm)
		if ($Algo) {
			# find pool by algorithm
			$Pool = Get-Pool($Algo)
			if ($Pool) {
				$coin = [string]::Empty
				$fee = 2
				switch ($Algo) {
					"equihash144" { $coin = "AUTO144_5" }
					"equihash192" { $coin = "AUTO192_7" }
					"equihash96" { $coin = "MNX"; $fee = 1 }
					"equihashBTG" { $coin = "BTG" }
				}
				$extrargs = Get-Join " " @($Cfg.ExtraArgs, $_.ExtraArgs)
				[MinerInfo]@{
					Pool = $Pool.PoolName()
					PoolKey = $Pool.PoolKey()
					Name = $Name
					Algorithm = $Algo
					Type = [eMinerType]::nVidia
					API = "lol"
					URI = "http://mindminer.online/miners/lolMiner_v05.zip"
					Path = "$Name\lolMiner.exe"
					ExtraArgs = $extrargs
					Arguments = "--coin $coin --pool $($Pool.Host) --port $($Pool.PortUnsecure) --user $($Pool.User) --pass $($Pool.Password) --apiport 4068 --timeprint 1 --disable_memcheck 1 --devices NVIDIA $extrargs"
					Port = 4068
					BenchmarkSeconds = if ($_.BenchmarkSeconds) { $_.BenchmarkSeconds } else { $Cfg.BenchmarkSeconds }
					RunBefore = $_.RunBefore
					RunAfter = $_.RunAfter
					Fee = $fee
				}
				[MinerInfo]@{
					Pool = $Pool.PoolName()
					PoolKey = $Pool.PoolKey()
					Name = $Name
					Algorithm = $Algo
					Type = [eMinerType]::AMD
					API = "lol"
					URI = "http://mindminer.online/miners/lolMiner_v05.zip"
					Path = "$Name\lolMiner.exe"
					ExtraArgs = $extrargs
					Arguments = "--coin $coin --pool $($Pool.Host) --port $($Pool.PortUnsecure) --user $($Pool.User) --pass $($Pool.Password) --apiport 4028 --timeprint 1 --disable_memcheck 1 --devices AMD $extrargs"
					Port = 4028
					BenchmarkSeconds = if ($_.BenchmarkSeconds) { $_.BenchmarkSeconds } else { $Cfg.BenchmarkSeconds }
					RunBefore = $_.RunBefore
					RunAfter = $_.RunAfter
					Fee = $fee
				}
			}
		}
	}
}