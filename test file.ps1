Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;

public class DialogBox
{
    public static void Main()
    {
        MessageBox.Show("THIS SCRIPT WORKED NOW GO SYM!", "Script Execution", MessageBoxButtons.OK, MessageBoxIcon.Information);
    }
}
"@

[DialogBox]::Main()
