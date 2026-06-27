# 🧺 Washing Machine Controller (Verilog HDL)

A modular RTL implementation of an **Automatic Washing Machine Controller** using **Verilog HDL**. The design is based on a **Finite State Machine (FSM)** architecture and supports multiple washing modes with timer-based phase control.

## ✨ Features

* FSM-based controller
* Quick, Normal & Heavy wash modes
* Modular RTL design
* Pause / Resume support
* Cancel operation
* Door safety detection
* Error handling
* Parameterized phase timer
* Self-checking Verilog testbench

---

## 🏗️ Project Structure

```
├── top_module.v
├── fsm_controller.v
├── mode_decoder.v
├── phase_timer.v
├── washing_machine_tb.v
└── docs/
    └── images/
```

---

## 📌 FSM States

```
IDLE
 ↓
FILL_WASH
 ↓
WASH
 ↓
DRAIN_AFTER_WASH
 ↓
FILL_RINSE
 ↓
RINSE
 ↓
DRAIN_AFTER_RINSE
 ↓
SPIN
 ↓
DONE
```

Additional states:

* PAUSE
* DRAIN_CANCEL
* ERROR

---

## 🧪 Verification

The design is verified using a **self-checking Verilog testbench**.

### Test Cases

* ✅ Normal Wash Cycle
* ✅ Pause / Resume
* ✅ Door Safety / Error
* ✅ Reset Verification

## 🛠️ Tools

* Verilog HDL
* Xilinx Vivado 2025.2
* Git & GitHub

## 👨‍💻 Author

**Yash Yadav**

Electrical Engineering, IIT Ropar

GitHub: https://github.com/yASHyadav09-png
