Hey Wes and team,

I've taken an initial look at the datasets you provided:

**Assumptions**

I assume this is a sample of data from a larger set, given that there are mostly users from Wisconsin and the majority of scans happened in January and February of 2021. I assume we are primarily interested in analyzing the performance of known partner brands, although other receipt data could be relevant and useful for others.

**Findings**

In terms of data quality, there are several areas of concern:
1. The user dataset contains duplicates for a large number of users. Additionally, it contains Fetch Staff user accounts-- unless we need to include them, I have removed them from analysis.
2. The values for some of the receipts are not stored in data types one would expect for a few fields, e.g. `TotalSpent` is stored as a string. We should discuss if we expect this to ever be anything other than a dollar value or null so we can handle it accordingly.
3. The brand data seems sparse-- I did the best I could to match it with the receipt data, but a low percentage have matched on `brandCode`/`barcode`. Additionally, some of the barcodes seem to be the same as the `brandCode` (mostly magazines and health & wellness items it seems) as well as the `ItemNumber`. I'll commit to documenting cross-system synonymous fields in our data docs if someone can explain so it's clear going forward.
4. Regarding barcodes specifically, there is a mix of GTIN, UPC, PLU, and ASIN barcodes. Luckily for the most common (GTIN-12) the checksums seem correct. 

**Questions**

- What percentage of matched `barcode` / `brandCode` is typical?
- Are the largest transactions (4k+ spent, 600+ items) within the normal distribution, or should receipts like this be dropped or at least marked as an outlier of some sort?
- Who on the team is in charge of the format/schema of the JSON files we received? What is the process of getting something changed or added? How often is it changed?


**Recommendations**

There are other things to address (e.g. test barcodes/brands, special characters, data profiling results) but the above issues need to be handled first so we can get more robust insights -- the comparison for different months won't be meaningful without a full dataset, unless there is a different focus of understanding for this data (e.g. testing new technology, detecting fraud, general reporting, etc.). I've kept the data modeling flexible, however, fuzzy logic to do matching of brands to receipts will not scale, so it is important that we keep the brand data up-to-date and/or have access to an API to fetch fresh barcodes and load into the database.


If anyone would like to look at the data profile reports for more details, please check the link [here](https://github.com/AF414/fetch/data_quality/), or just reply to this email with the dataset(s) you are interested in seeing.


Thanks and have a nice week!

Best regards,
Andrew