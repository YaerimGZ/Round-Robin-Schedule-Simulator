extends Control

var counter = 0		#Timer counter
var velocity = 'normal'		#Simulation speed
var process = 0		#Current process made
var pro = ''		#To find processes index on other lists
var processes = []		#List of processes 
var ready = []		#List of ready
var running = []	#List of running
var waitingIO = [] 	#List of waiting for IO
var terminated = []		#List of terminated processes
var usingIO = []		#List of processes using IO
var arrivingTime = []		#List of arrivingTime (not changable)
var durations = []		#List of durations (not changable)
var printerUse = []		#List of processes that are going to use printer (not changable)
var printerUseTime = []		#List of printer using time of each process (not changable)
var arrivingIOTime = []		#List of arriving time to the IO of each process (not changable)
var progress = []	#Execution progress of each process (not changable)
var executing = 0
var using = 0
var usingCalled = 0
var runningCalled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Parameters/Slider1.value = 50
	$Parameters/Slider2.value = 5
	$Parameters/Slider3.value = 20
	$Parameters/Slider4.value = 50
	$Parameters/Slider5.value = 20
	$Parameters/Slider6.value = 20
	$Headers/Base/ParametersButton.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Parameters/GenVal.text = str($Parameters/Slider1.value)
	$Parameters/QuanVal.text = str($Parameters/Slider2.value)
	$Parameters/DurVal.text = str($Parameters/Slider3.value)
	$Parameters/PrinterUVal.text = str($Parameters/Slider4.value)
	$Parameters/PrinterTVal.text = str($Parameters/Slider5.value)
	$Parameters/MaxProcVal.text = str($Parameters/Slider6.value)
	
	if velocity == 'slow':
		$"Quantum Timer/Timer/Timer".wait_time = 2
	if velocity == 'normal':
		$"Quantum Timer/Timer/Timer".wait_time = 1
	if velocity == 'fast':
		$"Quantum Timer/Timer/Timer".wait_time = 0.5

func _on_Timer_timeout():
	counter = counter + 1
	$"Quantum Timer/Timer".text = str(counter)
	if process < int($Parameters/MaxProcVal.text):
		processGeneration()
	if processes.empty() == false:
		readyQueue()
	if running.empty() == true && arrivingTime.empty() == false && (arrivingTime[0] + 2) == int($"Quantum Timer/Timer".text):
		runningCalled = true
		runningQueue()
	if running.empty() == true && runningCalled == true:
		runningQueue()
	if running.empty() == false:
		runningProcess()
	if waitingIO.empty() == false:
		if usingCalled == 0:
			usingCalled = 1
		elif usingIO.empty() == true:
			usingIO.append(waitingIO[0])
			$UsingIOL.add_item(usingIO[0])
			$WaitingForIOL.remove_item(0)
			waitingIO.remove(0)
			
			var pro1 = usingIO[0]
			pro1.erase(0,1)
			arrivingIOTime[int(pro1)-1] = (int($"Quantum Timer/Timer".text))
			$PCB/ArrivingIOTimeL.set_item_text((int(pro1)-1), str(arrivingIOTime[int(pro1)-1]))
	if usingIO.empty() == false:
		usingIO()
		usingCalled = 0
	
func processGeneration():
	var percentage = float($Parameters/GenVal.text) * 0.01
	randomize()
	var percent = randf()
	
	if percent < percentage:
		process = process + 1
		processes.append('P' + str(process))
		$HoldL.add_item(processes.back())
		$PCB/IDL.add_item(processes.back())
		$PCB/AccumulatedTimeL.add_item('0')
		
		var arrive = 0
		arrive = int($"Quantum Timer/Timer".text)
		arrivingTime.append(arrive)
		$PCB/ArrivingTimeL.add_item(str(arrivingTime.back()))
		durationGeneration()
		printerUseGeneration()
		printerUseTimeGeneration()

func durationGeneration():
	var average = int($Parameters/DurVal.text)
	randomize()
	var duration = randi() % ((average + 5) - (average - 5)) + (average - 5)
	if duration == 0:
		duration = 1
	durations.append(duration)
	arrivingIOTime.append(0)
	$PCB/DurationL.add_item(str(durations.back()))
	$PCB/ArrivingIOTimeL.add_item(str(arrivingIOTime.back()))

func printerUseGeneration():
	var percentage = float($Parameters/PrinterUVal.text) * 0.01
	randomize()
	var percent = randf()
	
	if percent < percentage:
		printerUse.append("Yes")
	else:
		printerUse.append("No")
	
	$PCB/PrinterUsageL.add_item(str(printerUse.back()))

func printerUseTimeGeneration():
	
	if printerUse.back() == "Yes": 
		var average = int($Parameters/PrinterTVal.text)
		randomize()
		var printerTime = randi() % ((average + 5) - (average - 5)) + (average - 5)
		printerUseTime.append(printerTime)
	if printerUse.back() == "No":
		printerUseTime.append(0)
	
	$PCB/IOUsageL.add_item(str(printerUseTime.back()))

func readyQueue():
	pro = processes.front()
	pro.erase(0, 1)
	if (arrivingTime[int(pro)-1] + 1) == int($"Quantum Timer/Timer".text) && $ReadyL.get_item_count() <= int($Parameters/MaxProcVal.text):
		$HoldL.remove_item(0)
		ready.append(processes.front())
		$ReadyL.add_item(processes.front())
		processes.remove(0)

func runningQueue():
	if $ReadyL.get_item_text(0) != '':
		$RunningL.add_item($ReadyL.get_item_text(0))
		running.append($ReadyL.get_item_text(0))
		$ReadyL.remove_item(0)
		ready.remove(0)
		progress.append(0)
	
func runningProcess():
	pro = running[0]
	pro.erase(0,1)
	executing = executing + 1
	progress[int(pro)-1] = progress[int(pro)-1] + 1
	$PCB/AccumulatedTimeL.set_item_text((int(pro)-1), str(progress[int(pro)-1] - 1))
	#for process in ready:
	#	var proReady = process
	#	proReady.erase(0,1)
	if progress[int(pro)-1] >= durations[int(pro)-1] + 1:
		if printerUse[int(pro)-1] == "Yes":
			waitingQueue()
		else:
			terminated.append(running[0])
			$IDL.add_item(running[0])
			var workingTime = int($PCB/DurationL.get_item_text(int(pro)-1)) + int($PCB/IOUsageL.get_item_text(int(pro)-1))
			$WorkingTimeL.add_item(str(workingTime))
			var systemTime = int($"Quantum Timer/Timer".text) - arrivingTime[int(pro) - 1]
			$SystemTimeL.add_item(str(systemTime))
			var waitingTime = systemTime - workingTime
			$WaitingTimeL.add_item(str(waitingTime))
			var performance = str(int(round((float(workingTime) / systemTime) * 100)))
			$PerformanceL.add_item(str(performance) + "%")
			$RunningL.remove_item(0)
			running = []
			executing = 0
	
	elif executing == int($"Parameters/QuanVal".text) + 1:
		if printerUse[int(pro)-1] == "Yes":
			waitingQueue()
		else:
			ready.append(running[0])
			$ReadyL.add_item(running[0])
			$RunningL.remove_item(0)
			running = []
			executing = 0

func waitingQueue():
	$WaitingForIOL.add_item(running[0])
	$RunningL.remove_item(0)
	waitingIO.append(running[0])
	running = []
	executing = 0

func usingIO():
	pro = usingIO[0]
	pro.erase(0,1)
	using = using + 1
	
	if using == printerUseTime[int(pro)-1] + 1:
		printerUse[int(pro)-1] = "No"
		ready.append(usingIO[0])
		$ReadyL.add_item(usingIO[0])
		$UsingIOL.remove_item(0)
		usingIO = []
		using = 0

func _on_ParametersButton_pressed():
	$Parameters.visible = true

func _on_PCBButton_pressed():
	$PCB.visible = true

func _on_Stop_pressed():
	counter = 0
	$"Quantum Timer/Timer".text = str(counter)
	$"Quantum Timer/Timer/Timer".stop()
	velocity = 'normal'
	process = 0
	pro = ''
	processes = []
	ready = []
	running = []
	waitingIO = []
	terminated = []
	usingIO = []
	arrivingTime = []
	durations = []
	printerUse = []
	printerUseTime = []
	arrivingIOTime = []
	progress = []
	executing = 0
	using = 0
	usingCalled = 0
	runningCalled = false
	$HoldL.clear()
	$ReadyL.clear()
	$RunningL.clear()
	$WaitingForIOL.clear()
	$UsingIOL.clear()
	$IDL.clear()
	$SystemTimeL.clear()
	$WorkingTimeL.clear()
	$WaitingTimeL.clear()
	$PerformanceL.clear()
	$PCB/IDL.clear()
	$PCB/ArrivingTimeL.clear()
	$PCB/DurationL.clear()
	$PCB/AccumulatedTimeL.clear()
	$PCB/PrinterUsageL.clear()
	$PCB/IOUsageL.clear()
	$PCB/ArrivingIOTimeL.clear()

func _on_Help_pressed():
	$Help.visible = true

func _on_Play_pressed():
	$"Quantum Timer/Timer/Timer".start()
	$Headers/Base/ParametersButton.visible = false

func _on_Pause_pressed():
	$"Quantum Timer/Timer/Timer".stop()
	$Headers/Base/ParametersButton.visible = true

func _on_Slow_pressed():
	velocity = 'slow'

func _on_Normal_pressed():
	velocity = 'normal'

func _on_Fast_pressed():
	velocity = 'fast'

func _on_Parameters_hide():
	$Headers/Base/ParametersButton.visible = false

func _on_Pause_focus_exited():
	if $Headers/Base/ParametersButton.is_hovered():
		$Headers/Base/ParametersButton.visible = true
	else:
		$Headers/Base/ParametersButton.visible = false
