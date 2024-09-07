## Prerequesites

1. Have `ruby` and `bundler` installed, versions don't matter.

## Usage

1. In a terminal session, run `ruby evionica-to-capzlog.rb`.
2. Input your name, to be able to determine if you were PIC, PICUS or SPIC for each flight.
3. Enter your skilltest's DPE name to be able to label the skilltest as PIC time.
4. Enter the source csv as pathname (or add it as `source.csv` in the same folder and just click enter).
5. Enter the desired destination csv folder as pathname (or leave it empty to create a `destination.csv` file in your current folder).
6. Take the generated `destination.csv` and add it to `https://capzlog.aero/data/bulkimport`.

## Notes
1. Ensure the format is correct. The capzlog app should give you the following view after adding the file:
<img width="631" alt="image" src="https://github.com/user-attachments/assets/4cb78433-3362-44fb-9e37-7c12a69d83da">

2. After clicking "Start validation", there will be an error message due to the "SPIC Time" header name. Click on "Set a resolution" -> "Set the pilot function to SPIC" -> "Resolve all like this".
<img width="1019" alt="image" src="https://github.com/user-attachments/assets/2e082dc0-e050-43c9-86fe-8fb388a906e3">

3. You should now get a success screen showing the import results. Be sure to check the entries and correct any mistakes. Enjoy!
<img width="812" alt="image" src="https://github.com/user-attachments/assets/548ad903-4368-4903-912b-a74049be74be">

