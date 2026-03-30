# PAS Bubble Plot - Shiny App

Interactive R Shiny app for creating publication-quality bubble plots showing transcript 3' end positions relative to polyadenylation sites (PAS).

## 🚀 Live Demo

**[Try it online →](https://your-username.shinyapps.io/PAS_Shiny_App/)** *(deploy first, then add link)*

## 📊 What It Does

Creates publication-ready ggplot2 bubble plots showing:
- **Transcript 3' end positions** along genomic coordinates
- **Expression levels** across multiple conditions (bubble size = TPM)
- **PAS assignment** (color-coded by polyadenylation site)
- **Auto-assignment** of transcripts to nearest PAS within specified window

Perfect for alternative polyadenylation (APA) studies and isoform analysis.

## ✨ Features

- ✅ **Publication quality** - Native ggplot2 rendering
- ✅ **Multiple input methods** - Paste data, upload CSV, or use examples
- ✅ **Flexible** - Handles 2, 3, 4+ conditions and any number of PAS sites
- ✅ **Auto PAS assignment** - Transcripts assigned to nearest PAS
- ✅ **Customizable** - Adjust colors, titles, labels, window size
- ✅ **High-resolution output** - Download PNG (600 DPI) or PDF (vector)
- ✅ **Preview data** - See your data before plotting
- ✅ **Built-in instructions** - No external documentation needed

## 🖥️ Run Locally

### Quick Start
```r
# Install required packages
install.packages(c("shiny", "ggplot2", "ggrepel", "dplyr", "DT", "reshape2"))

# Run the app
shiny::runApp()
```

Or from command line:
```bash
R -e "shiny::runApp()"
```

The app will open in your browser at `http://127.0.0.1:####`

## 📁 Input Format

You need **3 simple CSV files**:

### 1. PAS Sites
```csv
pas,coord
long,40624962
medium,40627710
short,40628724
```

### 2. Transcript Info
```csv
tx_id,start
ENST001,40628980
ENST002,40627710
ENST003,40624962
```
*Note: Use `start` for minus-strand genes, `end` for plus-strand genes*

### 3. Expression Data
```csv
tx_id,WT,KD
ENST001,52.98,55.12
ENST002,24.56,17.89
ENST003,29.34,11.28
```
*Add more columns for additional conditions (e.g., Control, Treatment_1h, Treatment_6h, Treatment_24h)*

## 🎯 Usage

1. **Choose input method** in sidebar
   - **Paste Data** - Quick for small datasets
   - **Upload CSV** - For larger files
   - **Example Data** - Test with SMARCE1 data

2. **Provide your data** (3 files/text areas)

3. **Adjust settings** (optional)
   - PAS window size (default: 100bp)
   - Plot title
   - X-axis label
   - Show/hide transcript labels

4. **Click "Generate Plot"**

5. **Download** PNG (600 DPI) or PDF (vector)

## 🌐 Deploy Your Own

Deploy to shinyapps.io (free tier: 5 apps, 25 active hours/month):

```r
# Install rsconnect
install.packages("rsconnect")

# Configure account (first time only)
rsconnect::setAccountInfo(name='your-account', 
                          token='your-token',
                          secret='your-secret')

# Deploy
rsconnect::deployApp()
```

Get your token/secret from [shinyapps.io/admin/#/tokens](https://www.shinyapps.io/admin/#/tokens)

## 💡 Tips

- **Transcripts not assigned?** Increase PAS window (try 200bp or 500bp)
- **Labels overlapping?** Turn off labels or use fewer transcripts
- **Wrong 3' ends?** Check you're using correct column for your gene's strand
- **Custom chromosome label?** Edit "X-axis Label" in settings (e.g., "chr17 coordinate (hg38)")

## 📦 Requirements

- R ≥ 4.0
- shiny
- ggplot2
- ggrepel
- dplyr
- DT
- reshape2

## 🐛 Troubleshooting

**App won't start?**
```r
# Check all packages installed
install.packages(c("shiny", "ggplot2", "ggrepel", "dplyr", "DT", "reshape2"))
```

**Plot looks weird?**
- Verify CSV format matches examples exactly
- Check for extra spaces or special characters
- Try example data first to confirm app works

**Deployment fails?**
- Check shinyapps.io account status
- Verify all packages in dependencies
- Check logs at shinyapps.io dashboard

## 📄 Citation

If you use this tool in a publication:

```
PAS Bubble Plot Shiny App
https://github.com/ghsamuel/PAS_Shiny_App
```

## 🔗 Related Tools

- **Standalone R Script** - [PAS_Plot](https://github.com/ghsamuel/PAS_Plot) - For batch processing
- **Streamlit Version** - Python-based alternative (in PAS_Plot repo)

## 📧 Contact

Questions or issues? [Open an issue](https://github.com/ghsamuel/PAS_Shiny_App/issues)

## 📜 License

Free to use and modify.

---

**Built with ❤️ using R Shiny + ggplot2**
