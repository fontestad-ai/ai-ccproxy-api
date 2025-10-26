# PyOxidizer configuration for ccproxy-api
# This builds a standalone binary executable for ccproxy

def make_exe():
    # Get the Python distribution to use (project requires >=3.11)
    dist = default_python_distribution(python_version="3.11")

    # Define the packaging policy
    policy = dist.make_python_packaging_policy()

    # Include all package resources
    policy.resources_location = "in-memory"
    policy.resources_location_fallback = "filesystem-relative:lib"

    # Allow file-based resources for compatibility
    policy.allow_files = True
    policy.file_scanner_emit_files = True

    # Include bytecode for performance
    policy.bytecode_optimize_level_zero = True
    policy.bytecode_optimize_level_one = False
    policy.bytecode_optimize_level_two = False

    # Create a Python interpreter configuration
    python_config = dist.make_python_interpreter_config()

    # Set to run as an application
    python_config.run_command = "from ccproxy.cli import main; main()"

    # Configure module search paths
    python_config.module_search_paths = ["$ORIGIN/lib"]

    # Optimize for application startup
    python_config.optimization_level = 0
    python_config.write_modules_directory_env = "PYOXIDIZER_MODULES_DIR"

    # Create the packaging environment
    python_packaging = dist.make_python_packaging_policy()
    python_packaging.resources_location = "in-memory"
    python_packaging.resources_location_fallback = "filesystem-relative:lib"

    # Resolve package dependencies using pip
    exe = dist.to_python_executable(
        name="ccproxy",
        packaging_policy=policy,
        config=python_config,
    )

    # Install the application and dependencies
    # Use pip install to get the current package and all dependencies
    exe.add_python_resources(exe.pip_install(["."]))

    return exe

def make_embedded_resources(exe):
    return exe.to_embedded_resources()

def make_install(exe):
    # Create an install layout
    files = FileManifest()

    # Add the executable
    files.add_python_resource(".", exe)

    return files

def make_msi(exe):
    # MSI installer configuration for Windows
    return exe.to_wix_msi_builder(
        "ccproxy",
        "CCProxy API",
        "0.1.0",
        "CaddyGlow"
    )

# Register build targets
register_target("exe", make_exe)
register_target("resources", make_embedded_resources, depends=["exe"], default=True)
register_target("install", make_install, depends=["exe"], default_build_script=True)
register_target("msi", make_msi, depends=["exe"])

# Resolve the targets
resolve_targets()
