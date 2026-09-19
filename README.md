# CG3207 Project

This repository contains the shared source files for the FPGA project.

> **Important:** Do not upload your entire Vivado project to this repository.
> Ceate your own Vivado project locally and add the
> source files from this repository.

## 1. Clone the Repository

Clone the repository to your computer:

```bash
git clone https://github.com/fookang/CG3207
cd https://github.com/fookang/CG3207
```

## 2. Create a Vivado Project

Open **Vivado** and select:

**Create Project → Next**

Choose a location for your Vivado project.

Create the Vivado project **outside of this Git repository**
so that Vivado-generated files are not accidentally committed.


## 3. Select the FPGA

When Vivado asks for the **Default Part**, select the **Parts** tab and use the
following filters:

| Setting | Value |
|---|---|
| Family | Artix-7 |
| Package | csg324 |
| Speed Grade | -1 |

Select the following FPGA:

```text
xc7a100tcsg324-1
```

This is the FPGA used by the **Nexys 4** board.

Click **Next**, then **Finish**.

## 4. Add the Source Files

In Vivado, select:

**Add Sources → Add or Create Design Sources**

Add the required `.vhd` files from the cloned repository.

When adding existing source files, **do not copy the files into your Vivado
project**. The Vivado project should reference the files inside the Git
repository.

For example:

```text
FPGA-Git/
└── src/
    ├── top.vhd
    ├── module_a.vhd
    └── module_b.vhd
```

This ensures that when you edit a VHDL file in Vivado, Git can detect the
changes.

Add the constraint (`.xdc`) files in the same way using:

**Add Sources → Add or Create Constraints**

## 5. Working on a Feature

Do not work directly on `main` or `develop`.

Before starting your work, update `develop`:

```bash
git checkout asst2 
git pull
```

Create your own branch:

```bash
git checkout -b feature/<feature-name>
```

For example:

```bash
git checkout -b feature/uart
```

Make your changes and test them in Vivado.

When ready:

```bash
git add .
git commit -m "Implement UART module"
git push -u origin feature/uart
```

Then create a Pull Request on GitHub:

```text
feature/uart
     |
     v
   asst2 
```

Do **not** create the Pull Request directly into `main`.

## 6. Integration

Individual features are merged into:

```text
feature/* ── PR ──> asst2
```

The `asst2` branch is used to integrate and test everyone's work.

Once the complete FPGA design has been tested and is ready:

```text
asst2 ── PR ──> main
```

`main` should therefore contain the stable version of the project.

## Branch Structure

```text
main
  ^
  |
  | Final PR
  |
asst2
  ^
  |
  +---- feature/module-a
  |
  +---- feature/module-b
  |
  +---- feature/module-c
```

## Important Rules

- Do not push directly to `main`.
- Do not push directly to `asst2`.
- Create a separate branch for your work.
- Create a Pull Request into `asst2` when your work is ready.
- Do not commit Vivado-generated project files.
- Only commit source files, constraints, and other files required by the team.
- Make sure your design works in Vivado before creating a Pull Request.
