DROP VIEW if exists PercentPopulationVac
USE YoutubeProject
GO

SELECT *
FROM YoutubeProject..CovidDataAugust
WHERE location like '%indo%'

--Percent Vaccinate
CREATE VIEW PercentPopulationVac AS 
Select continent, location, date, population, new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by location Order by location, date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM YoutubeProject..CovidDataAugust
where continent is not null 
--order by 2,3


Select TOP (1000) *,(RollingPeopleVaccinated/population)*100
FROM PercentPopulationVac