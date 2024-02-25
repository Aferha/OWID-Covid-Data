# OWID-Covid-Data
Up-to-date COVID data is based on numbers reported from each country.

In this project, all data is gathered from Our World In Data, last data was collected from Jan 21, 2024.

The project is divided into multiple SQL queries, for easier understanding of what data the user is trying to get. A compiled list with description is as follows:

| Query | Description |
| ------------- | ------------- |
| 1. **Total Cases vs Total Deaths** | Percentage of people dead compared to the total number of cases |
| 2. **Total Cases vs Population** | Percentage of people infected |
| 3. **Countries with Highest Infection Rate compared to Population** | Which countries have the highest infection rate throughout the world |
| 4. **Countries with Highest Death Count per Population** | Total number of deaths per country, in descending order |
| 5. **Continent Numbers** | Total deaths per continent |
| 6. **Global Numbers** | Total deaths numbers and percentage |
| <p> 7. **Total Population vs Vaccinations** <p>- _Using CTE to perform Calculation on Partition by_ <p> - _Using CTE to perform Calculation on Partition by_ | Addition of new vaccine batches and total number of people vaccinated after each batch |
| 8. **Creating Views** | Create all tables to be used in Tableau |

Throughout the code, the commented line:
```SQL
WHERE location LIKE '%Mexico%'
```
Would allow the user to only look at numbers provided from Mexico. This line can be modified to whichever country the user is interested in knowing the information from.

The conclusion of this project comes to fruition in a public Tableau dashboard to show the recollected data.
Link to [Tableau Dashboard](https://public.tableau.com/app/profile/fernando.herrera2734/viz/OWIDWorldCovidData/Dashboard1)
![OWIDTableuDashboard](https://github.com/Aferha/OWID-Covid-Data/assets/83234611/833de76f-ea97-4860-828d-f976a73f30b9)
