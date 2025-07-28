
# MyPipelineModule.psm1
# This module demonstrates how to accept pipeline input in functions.

function Get-Greeting {
    [CmdletBinding()]
    param(
        # This parameter accepts a string value directly from the pipeline.
        [Parameter(ValueFromPipeline = $true)]
        [string]$Name
    )

    process {
        "Hello, $Name!"
    }
}

function Get-EmployeeInfo {
    [CmdletBinding()]
    param(
        # This parameter accepts input from a property named 'Name' on a pipeline object.
        [Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
        [string]$Name,

        # This parameter accepts input from a property named 'Department' on a pipeline object.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Department
    )

    process {
        if ($Department) {
            "Employee: $Name, Department: $Department"
        } else {
            "Employee: $Name, Department: Not Specified"
        }
    }
}

# Export the functions to make them available when the module is imported.
Export-ModuleMember -Function Get-Greeting, Get-EmployeeInfo

