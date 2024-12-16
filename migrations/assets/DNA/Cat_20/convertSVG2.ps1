# Function to parse SVG content into rect data array
function Parse-SVGToRectData {
    param (
        [string]$svgString,
        [string]$fileName
    )

    # Create a temporary file for XML parsing
    $tempFile = New-TemporaryFile
    try {
        # Write SVG string to temporary file
        $svgString | Out-File -FilePath $tempFile.FullName -Encoding utf8

        # Use XML to parse the SVG file
        $xmlDoc = New-Object System.Xml.XmlDocument
        $xmlDoc.Load($tempFile.FullName)

        $rects = $xmlDoc.GetElementsByTagName("rect")
        $x = @()
        $y = @()
        $color = @()

        # Process each rect element
        foreach ($rect in $rects) {
            $x += $rect.GetAttribute("x").ToString()
            $y += $rect.GetAttribute("y").ToString()
            $color += $rect.GetAttribute("fill")
        }

        # Return the data in the desired format
        return @{
            name = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
            x = $x
            y = $y
            color = $color
        }
    }
    finally {
        # Clean up the temporary file
        Remove-Item -Path $tempFile.FullName -Force
    }
}

# Get all SVG files in current directory
$svgFiles = Get-ChildItem -Filter "*.svg"

foreach ($file in $svgFiles) {
    # Read SVG content
    $content = Get-Content -Path $file.FullName -Raw
    
    # Regular expression to match path elements with 1x1 rect pattern
    # Matches pattern like: <path d="M6 7H5V8H6V7Z" fill="#878787"/>
    $regex = '<path\s+d="M(\d+)\s+(\d+)H(\d+)V(\d+)H(\d+)V(\d+)Z"\s+fill="([^"]+)"\s*/>'
    
    # Replace function to convert path to rect
    $newContent = [regex]::Replace($content, $regex, {
        param($match)
        
        # Extract coordinates and dimensions
        $x1 = [int]$match.Groups[1].Value
        $y1 = [int]$match.Groups[2].Value
        $x2 = [int]$match.Groups[3].Value
        $y2 = [int]$match.Groups[4].Value
        
        # Calculate rect parameters
        $x = [Math]::Min($x1, $x2)
        $y = [Math]::Min($y1, $y2)
        $width = [Math]::Abs($x1 - $x2)
        $height = [Math]::Abs($y1 - $y2)
        
        # Only convert if it's a 1x1 rectangle
        if ($width -eq 1 -and $height -eq 1) {
            return "<rect x=`"$x`" y=`"$y`" width=`"1`" height=`"1`" fill=`"$($match.Groups[7].Value)`"/>"
        }
        
        # Return original path if not a 1x1 rectangle
        return $match.Groups[0].Value
    })

    # Remove all elements except rect between svg tags
    $svgStartTag = "<svg[^>]*>"
    $svgEndTag = "</svg>"
    $rectElements = "<rect[^>]*>"

    # Extract svg opening tag
    if ($newContent -match $svgStartTag) {
        $openingSvgTag = $matches[0]
    }

    # Get all rect elements
    $rects = [regex]::Matches($newContent, $rectElements) | ForEach-Object { $_.Value }

    # Construct new SVG with only rect elements
    $cleanedSvg = $openingSvgTag
    $rects | ForEach-Object { $cleanedSvg += "`n  $_" }
    $cleanedSvg += "`n</svg>"
    
    # Save modified content back to file
    $cleanedSvg | Set-Content -Path $file.FullName -NoNewline
    Write-Host "Processed: $($file.Name)"
}

# Array to hold all the parsed data
$allData = @()

foreach ($file in $svgFiles) {
    $svgContent = Get-Content $file.FullName -Raw
    $parsedData = Parse-SVGToRectData -svgString $svgContent -fileName $file.Name
    $allData += $parsedData
}

# Name for the output JSON file
$outputJsonFile = "output.json"

# Convert the data to JSON and save it in the current directory
$jsonContent = $allData | ConvertTo-Json -Depth 100
$jsonContent | Out-File -FilePath $outputJsonFile -Encoding utf8

Write-Output "JSON file '$outputJsonFile' has been created in the current directory."