--1--
SELECT P.playerID AS playerid, nameFirst as firstname, nameLast AS lastname, SUM(COALESCE(CS, 0)) AS total_caught_stealing FROM people AS P, batting AS B WHERE P.playerID = B.playerID GROUP BY P.playerID, nameFirst, nameLast ORDER BY sum(COALESCE(CS, 0)) DESC, nameFirst ASC, nameLast ASC, P.playerID ASC LIMIT 10;

--2--
SELECT P.playerID AS playerid, nameFirst AS firstname, sum(runscore) AS runscore FROM people AS P, (SELECT playerID, (2*COALESCE(h2b, 0)+3*COALESCE(h3b, 0)+4*COALESCE(hr, 0)) AS runscore FROM batting) AS B WHERE P.playerID = B.playerID GROUP BY P.playerID, P.nameFirst ORDER BY sum(runscore) DESC, P.nameFirst DESC, P.playerID ASC limit 10;

--3--
SELECT P.playerID, case when P.nameFirst is NOT NULL then COALESCE(nameFirst, '') ||' '|| COALESCE(nameLast, '') else P.nameLast end as playername, sum(pointswon) as total_points FROM people AS P, (SELECT * FROM awardsshareplayers WHERE yearID>=2000) AS A WHERE P.playerID = A.playerID GROUp BY P.playerID, P.nameFirst, P.nameLast ORDER BY total_points DESC, P.playerID ASC;

--4--
SELECT P.playerID AS playerid, P.nameFirst AS firstname, P.nameLast AS lastname, avg(bat_avg) as career_batting_average FROM people AS P, (SELECT *, (h::decimal/ab::decimal) AS bat_avg FROM batting WHERE playerID in (SELECT playerID FROM batting GROUP BY playerID HAVING count(DISTINCT yearID)>=10) AND ab is NOT NULL AND h is NOT NULL AND ab!='0') AS B WHERE P.playerID = B.playerID GROUP BY P.playerId, P.nameFirst, P.nameLast ORDER BY career_batting_average DESC, P.playerID ASC, P.nameFirst ASC, P.nameLast ASC limit 10;

--5--
SELECT P.playerID AS playerid, P.nameFirst AS firstname, P.nameLast AS lastname, (case when birthYear is NULL then '' when birthMonth is NULL then '' when birthDay is NULL then '' else (birthYear || '-' || lpad(birthMonth::text, 2, '0') || '-' || lpad(birthDay::text, 2, '0')) end) AS date_of_birth, num_seasons FROM people AS P, (SELECT playerID, count(DISTINCT yearID) AS num_seasons FROM appearances GROUP BY playerID) AS A WHERE P.playerID = A.playerID ORDER BY A.num_seasons DESC, P.playerID ASC, P.nameFirst ASC, P.nameLast ASC, date_of_birth ASC;

--6--
CREATE VIEW latest_teamname AS (SELECT * FROM (SELECT teamID, name, row_number() OVER (PARTITION BY teamID ORDER BY yearID DESC) AS row_number FROM teams) AS temp WHERE row_number = 1);
SELECT T.teamID AS teamid, LT.name AS teamname, F.franchName AS franchisename, max(T.W) AS num_wins FROM teamsfranchises AS F, (SELECT teamID, franchID, W, name FROM teams WHERE DivWin='Y') AS T, latest_teamname AS LT WHERE F.franchID = T.franchID AND LT.teamID = T.teamID GROUP BY T.teamID, LT.name, F.franchName ORDER BY num_wins DESC, T.teamID ASC, LT.name ASC, F.franchName ASC;

--7--
CREATE VIEW latest_teamname AS (SELECT * FROM (SELECT teamID, name, row_number() OVER (PARTITION BY teamID ORDER BY yearID DESC) AS row_number FROM teams) AS temp WHERE row_number = 1);
SELECT A.teamid, B.name AS teamname, seasonid, winning_percentage FROM (with win_per (teamid, name, yearid, w, per) as ( select t.teamid as teamid, t.name as name, t.yearid as yearid ,t.w as w, ((coalesce ((t.w*1.0),0))/coalesce(t.g,0))*100 as per from teams t) Select teamid, teamname, seasonid, winning_percentage, rn from ( select p.teamid as teamid, p.name as teamname, p.yearid as seasonid, p.per as winning_percentage, row_number() over (partition by p.teamid order by p.per desc) as rn from win_per p where p.w>=20 )as x where rn = 1 order by winning_percentage desc, teamid asc, teamname asc, seasonid asc limit 5) AS A, latest_teamname AS B WHERE A.teamid = B.teamID order by winning_percentage desc, teamid asc, teamname asc, seasonid asc limit 5;

--8--
CREATE VIEW latest_teamname AS (SELECT * FROM (SELECT teamID, name, row_number() OVER (PARTITION BY teamID ORDER BY yearID DESC) AS row_number FROM teams) AS temp WHERE row_number = 1);
SELECT DISTINCT ON (teamid, teamname, seasonid, playerid, firstname, lastname, salary) S.teamID AS teamid, LT.name AS teamname, S.yearID AS seasonid, S.playerID as playerid, P.nameFirst as firstname, P.nameLast as lastname, S.salary as salary FROM latest_teamname AS LT, people as P, teams as T, salaries as S, (SELECT teamID, yearID, max(salary) AS salary FROM salaries GROUP BY teamID, yearID) AS SS WHERE S.playerID = P.playerID AND S.teamID = T.teamID AND S.salary = SS.salary AND SS.teamID = S.teamID AND S.yearID = SS.yearID AND LT.teamID = T.teamID ORDER BY S.teamID, LT.name, S.yearID, S.playerID, P.nameFirst, P.nameLast, S.salary DESC;

--9--
with F(player_category, avg_salary) AS (SELECT 'batsman'::text AS player_category, avg(COALESCE(salary, 0)) AS salary FROM batting AS B, salaries AS S WHERE B.playerID =  S.playerID AND B.yearID =  S.yearID AND B.teamID =  S.teamID), L(player_category, avg_salary) AS (SELECT 'pitcher'::text AS player_category, avg(COALESCE(salary, 0)) AS salary FROM pitching AS P, salaries AS S WHERE P.playerID = S.playerID AND P.teamID = S.teamID AND P.yearID = S.yearID), O(player_category, avg_salary) AS (SELECT * FROM F NATURAL FULL OUTER JOIN L) SELECT player_category, avg_salary FROM O WHERE avg_salary = (SELECT max(avg_salary) FROM O);

--10--
SELECT peep.playerID AS playerid, case when peep.nameFirst is NOT NULL then COALESCE(nameFirst, '') ||' '|| COALESCE(nameLast, '') else peep.nameLast end as playername, number_of_batchmates FROM people AS peep, (SELECT P.playerID, count(DISTINCT Q.playerID) AS number_of_batchmates FROM collegeplaying AS P, collegeplaying AS Q WHERE P.schoolID = Q.schoolID AND P.yearID = Q.yearID AND P.playerID <> Q.playerID GROUP BY P.playerID) AS sus WHERE peep.playerID = sus.playerID ORDER BY number_of_batchmates DESC, peep.playerID ASC;

--11--
CREATE VIEW latest_teamname AS (SELECT * FROM (SELECT teamID, name, row_number() OVER (PARTITION BY teamID ORDER BY yearID DESC) AS row_number FROM teams) AS temp WHERE row_number = 1);
SELECT T.teamID AS teamid, LT.name AS teamname, count(WSWin) AS total_WS_wins FROM teams AS T, latest_teamname AS LT WHERE T.G>=110 AND T.WSWin='Y' AND T.teamID = LT.teamID GROUP BY T.teamID, LT.name ORDER BY total_WS_wins DESC, T.teamID, LT.name limit 5;

--12--
SELECT P.playerID AS playerid, P.nameFirst AS firstname, P.nameLast AS lastname, career_saves, num_seasons FROM people AS P, (SELECT playerID, sum(SV) AS career_saves, count(DISTINCT yearID) AS num_seasons FROM pitching GROUP BY playerID HAVING count(DISTINCT yearID)>=15 ORDER BY career_saves DESC LIMIT 10) AS pit WHERE P.playerID = pit.playerID ORDER BY career_saves DESC, num_seasons DESC, P.playerID, P.nameFIrst, P.nameLast; 

--13--
CREATE VIEW latest_teamname AS (SELECT * FROM (SELECT teamID, name, row_number() OVER (PARTITION BY teamID ORDER BY yearID DESC) AS row_number FROM teams) AS temp WHERE row_number = 1);
SELECT playerid, firstname, lastname, birth_address, temp2.name AS first_teamname, temp3.name AS second_teamname FROM (SELECT P.playerID AS playerid, P.nameFirst AS firstname, P.nameLast AS lastname, case when birthCity IS NULL then '' when birthState IS NULL then '' WHEN birthCountry IS NULL then '' else lower(birthCity) || ' ' || lower(birthState) || ' ' || lower(birthCountry) end AS birth_address, (SELECT A.teamID AS first_teamname FROM (SELECT teamID, yearID, dense_rank() OVER(PARTITION BY yearID ORDER BY yearID ASC) AS dr FROM pitching WHERE playerID = P.playerID) AS A, (SELECT teamID, yearID, dense_rank() OVER(PARTITION BY yearID ORDER BY yearID ASC) AS dr FROM pitching WHERE playerID = P.playerID) AS B WHERE A.teamID != B.teamID ORDER BY A.yearID, B.yearID LIMIT 1) AS first_teamname, (SELECT B.teamID AS second_teamname FROM (SELECT teamID, yearID, dense_rank() OVER(PARTITION BY yearID ORDER BY yearID ASC) AS dr FROM pitching WHERE playerID = P.playerID) AS A, (SELECT teamID, yearID, dense_rank() OVER(PARTITION BY yearID ORDER BY yearID ASC) AS dr FROM pitching WHERE playerID = P.playerID) AS B WHERE A.teamID != B.teamID ORDER BY A.yearID, B.yearID LIMIT 1) AS second_teamname FROM people AS P WHERE P.playerID IN (SELECT playerID FROM pitching GROUP BY playerID HAVING count(DISTINCT teamID)>=5) ORDER BY playerid, firstname, lastname, birth_address, first_teamname, second_teamname) AS temp, latest_teamname AS temp2, latest_teamname AS temp3 WHERE temp.first_teamname = temp2.teamID AND temp.second_teamname = temp3.teamID ORDER BY playerid, firstname, lastname, birth_address, first_teamname, second_teamname;


--14--
INSERT INTO people(playerID, nameFirst, nameLast) VALUES('dunphil02', 'Phil', 'Dunphy');
INSERT INTO awardsplayers(playerID, awardID, yearID, lgID, tie, notes) VALUES('dunphil02', 'Best Baseman', 2014, '', 't', DEFAULT);
INSERT INTO people(playerID, nameFirst, nameLast) VALUES('tuckcam01', 'Cameron', 'Tucker');
INSERT INTO awardsplayers(playerID, awardID, yearID, lgID, tie, notes) VALUES('tuckcam01', 'Best Baseman', 2014, '', 't', DEFAULT);
INSERT INTO people(playerID, nameFirst, nameLast) VALUES('scottm02', 'Michael', 'Scott');
INSERT INTO awardsplayers(playerID, awardID, yearID, lgID, tie, notes) VALUES('scottm02', 'ALCS MVP', 2015, 'AA', DEFAULT, DEFAULT);
INSERT INTO people(playerID, nameFirst, nameLast) VALUES('waltjoe', 'Joe', 'Walt');
INSERT INTO awardsplayers(playerID, awardID, yearID, lgID, tie, notes) VALUES('waltjoe', 'Triple Crown', 2016, '', DEFAULT, DEFAULT);
INSERT INTO people(playerID, nameFirst, nameLast) VALUES('adamswil01', 'Willie', 'Adams');
INSERT INTO awardsplayers(playerID, awardID, yearID, lgID, tie, notes) VALUES('adamswil01', 'Gold Glove', 2017, '', DEFAULT, DEFAULT);
INSERT INTO people(playerID, nameFirst, nameLast) VALUES('yostne01', 'Ned', 'Yost');
INSERT INTO awardsplayers(playerID, awardID, yearID, lgID, tie, notes) VALUES('yostne01', 'ALCS MVP', 2017, '', DEFAULT, DEFAULT);
SELECT awardid, A.playerid, nameFirst as firstname, nameLast AS lastname, count AS num_wins FROM people, (SELECT * FROM (SELECT temp.*, rank() OVER(PARTITION BY temp.awardID ORDER BY temp.count DESC, temp.playerID ASC) AS rank FROM (SELECT awardID, playerID, count(yearID) FROM awardsplayers GROUP BY awardID, playerID) AS temp) AS temp2 WHERE rank=1) AS A WHERE A.playerID = people.playerID ORDER BY awardid ASC, num_wins DESC;

--15--
CREATE VIEW latest_teamname AS (SELECT * FROM (SELECT teamID, name, row_number() OVER (PARTITION BY teamID ORDER BY yearID DESC) AS row_number FROM teams) AS temp WHERE row_number = 1);
SELECT temp1.teamID AS teamid, LT.name AS teamname, temp1.yearID AS seasonid, temp2.playerID AS managerID, P.nameFirst AS managerfirstname, P.nameLast AS managerlastname FROM (SELECT DISTINCT ON (yearID, teamID, lgID) yearID, teamID, lgId, name FROM teams WHERE yearID >= 2000 AND yearID <=2010) AS temp1, (SELECT teamID, playerID, yearID, lgID, inseason, row_number() OVER (PARTITION BY teamID, yearID, lgID ORDER BY teamID) AS rn FROM managers WHERE inseason = 0 OR inseason = 1) AS temp2, people AS P, latest_teamname AS LT WHERE P.playerID = temp2.playerID AND temp1.yearID = temp2.yearID AND temp1.teamID = temp2.teamID AND temp1.lgID = temp2.lgID AND LT.teamID = temp1.teamID ORDER BY teamid, teamname, seasonid DESC, managerid, managerfirstname, managerlastname; 

--16--
SELECT playerid, COALESCE(colleges_name, '') AS colleges_name, total_awards FROM (SELECT B.playerID AS playerid, A.schoolName AS colleges_name, B.count AS total_awards FROM schools AS A RIGHT OUTER JOIN (SELECT playerID, count(awardID) AS count FROM awardsplayers GROUP BY playerID ORDER BY count DESC, playerID ASC LIMIT 10) AS B LEFT OUTER JOIN (SELECT * FROM(SELECT schoolID, playerID, rank() OVER (PARTITION BY playerID ORDER BY yearID DESC) AS rn FROM collegeplaying) AS temp WHERE rn = 1) AS C ON B.playerID = C.playerID ON C.schoolID = A.schoolID ORDER BY total_awards DESC, colleges_name, playerid) AS final;

--17--
SELECT A.playerID AS playerid, C.nameFirst AS firstname, C.nameLast AS lastname, A.awardID AS playerawardid, A.yearID AS playerawardyear, B.awardID AS managerawardid, B.yearID AS managerawardyear FROM (SELECT DISTINCT ON (playerID) * FROM (SELECT playerID, awardID, yearID, lgID, rank() OVER (PARTITION BY playerID ORDER BY yearID ASC, awardID ASC) AS rn FROM awardsplayers) AS P WHERE rn=1) AS A, (SELECT DISTINCT ON (playerID) * FROM (SELECT playerID, awardID, yearID, lgID, rank() OVER (PARTITION BY playerID ORDER BY yearID ASC, awardID ASC) AS rn FROM awardsmanagers) AS M WHERE rn=1) AS B, people AS C WHERE A.playerID = B.playerID AND A.playerID = C.playerID ORDER BY playerid, firstname, lastname;

--18--
SELECT DISTINCT C.playerID AS playerid, C.nameFirst AS firstname, C.nameLast AS lastname, A.count AS num_honoured_categories, B.yearID AS seasonid FROM (SELECT playerID, count(yearID) AS count FROM halloffame GROUP BY playerID HAVING count(yearID)>=2 ORDER BY playerID ASC) AS A, (SELECT * FROM(SELECT *, rank() OVER (PARTITION BY playerID ORDER BY yearID ASC) AS rn FROM allstarfull) AS asa WHERE rn=1) AS B, people AS C WHERE C.playerID = A.playerID AND A.playerID = B.playerID ORDER BY num_honoured_categories DESC, playerid, firstname, lastname, seasonid;

--19--
SELECT DISTINCT A.playerID AS playerid, A.nameFirst AS firstname, A.nameLast AS lastname, G_all, G_1b, G_2b, G_3b FROM people AS A, (SELECT playerID, sum(G_All) AS G_all, sum(G_1b) AS G_1b, sum(G_2b) AS G_2b, sum(G_3b) AS G_3b FROM appearances GROUP BY playerID HAVING (sum(G_1b)>0 AND sum(G_2b)>0) OR (sum(G_3b)>0 AND sum(G_2b)>0) OR (sum(G_1b)>0 AND sum(G_3b)>0) ORDER BY playerID) AS B WHERE A.playerID = B.playerID ORDER BY G_all DESC, playerid, firstname, lastname, G_1b DESC, G_2b DESC, G_3b DESC;

--20--
SELECT S.schoolID AS schoolid, S.schoolName AS schoolname, S.schoolCity || ' ' || S.schoolState AS schooladdr, P.playerID AS playerid, P.nameFirst as firstname, P.nameLast AS lastname FROM people AS P, (SELECT A.* FROM schools AS A, (SELECT schoolID FROM collegeplaying GROUP BY schoolID ORDER BY count(DISTINCT playerID) DESC LIMIT 5) AS B WHERE A.schoolID = B.schoolID) AS S, (SELECT DISTINCT ON (playerID, schoolID) * FROM collegeplaying) AS C WHERE C.playerID = P.playerID AND C.schoolID = S.schoolID ORDER BY schoolid, schoolname, schooladdr, playerid, firstname, lastname;

--21--
SELECT A.playerID AS player1_id, B.playerID  AS player2_id, A.birthCity AS birthcity, A.birthState AS birthstate, case when (exists ((SELECT DISTINCT teamID FROM pitching WHERE A.playerID = pitching.playerID) INTERSECT (SELECT DISTINCT teamID FROM pitching WHERE B.playerID = pitching.playerID))) AND (exists ((SELECT DISTINCT teamID FROM batting WHERE A.playerID = batting.playerID) INTERSECT (SELECT DISTINCT teamID FROM batting WHERE B.playerID = batting.playerID))) then 'both' else case when exists((SELECT DISTINCT teamID FROM batting WHERE A.playerID = batting.playerID) INTERSECT (SELECT DISTINCT teamID FROM batting WHERE B.playerID = batting.playerID)) then 'batted' else 'pitched' end end AS role FROM (SELECT * FROM people WHERE birthCity!='NULL' AND birthState!='NULL') AS A, (SELECT * FROM people WHERE birthCity!='NULL' AND birthState!='NULL') AS B WHERE A.playerID != B.playerID AND A.birthCity = B.birthCity AND A.birthState = B.birthState AND exists (((SELECT DISTINCT teamID FROM pitching WHERE A.playerID = pitching.playerID) INTERSECT (SELECT DISTINCT teamID FROM pitching WHERE B.playerID = pitching.playerID)) UNION ((SELECT DISTINCT teamID FROM batting WHERE A.playerID = batting.playerID) INTERSECT (SELECT DISTINCT teamID FROM batting WHERE B.playerID = batting.playerID)));

--22--
SELECT A.awardID AS awardid, A.yearID AS seasonid, A.playerID AS playerid, A.pointsWon AS playerpoints, B.avg AS averagepoints FROM awardsshareplayers AS A, (SELECT awardID, yearID, avg(pointsWON) AS avg FROM awardsshareplayers GROUP BY awardID, yearID ORDER BY awardID, yearID) AS B WHERE A.awardID = B.awardID AND A.yearID = B.yearID AND A.pointsWon >= B.avg ORDER BY awardid, seasonid, playerpoints DESC, playerid;

--23--
SELECT P.playerID, case when P.nameFirst is NOT NULL then COALESCE(nameFirst, '') ||' '|| COALESCE(nameLast, '') else P.nameLast end as playername, case when P.birthDay IS NULL AND P.birthYear IS NULL AND P.birthMonth IS NULL then 'False'::boolean else 'True'::boolean end AS alive FROM people AS P WHERE playerID NOT IN (SELECT DISTINCT playerID FROM awardsplayers) AND playerID NOT IN (SELECT DISTINCT playerID FROM awardsmanagers) ORDER BY playerid, playername;

--24--
CREATE VIEW g1_nodes(nodes) AS (SELECT DISTINCT playerID FROM (SELECT DISTINCT playerID FROM pitching) AS A UNION (SELECT DISTINCT playerID FROM allstarfull));
CREATE VIEW g1_edges(nodeA, nodeB, weight) AS (SELECT DISTINCT ON(playerIDA, playerIDB) playerIDA, playerIDB, count(yearIDA) AS weight FROM (WITH UPA(playerID, yearID, teamID) AS (SELECT * FROM (SELECT DISTINCT ON(playerID, yearID, teamID) playerID, yearID, teamID FROM pitching) AS A UNION ALL (SELECT DISTINCT ON(playerID, yearID, teamID) playerID, yearID, teamID FROM allstarfull WHERE GP=1)) SELECT A.playerID AS playerIDA, A.yearID AS yearIDA, A.teamID AS teamIDA, B.playerID AS playerIDB, B.yearID AS yearIDB, B.teamID AS teamIDB FROM UPA AS A, UPA AS B WHERE A.playerID != B.playerID AND A.yearID = B.yearID AND A.teamID = B.teamID) AS temp WHERE playerIDA != playerIDB AND yearIDA = yearIDB AND teamIDA = teamIDB GROUP BY playerIDA, playerIDB);
SELECT case when count(*)>0 then 'True'::boolean else 'False'::boolean end AS pathexists FROM (
SELECT DISTINCT * FROM (WITH RECURSIVE search_graph(nodeA, nodeB, weight, depth, path) AS 
( SELECT  nodeA, nodeB, weight AS path_length, 0, ARRAY[]::varchar[] || nodeA || nodeB AS path
  FROM g1_edges WHERE nodeA = 'webbbr01' 
 
  UNION ALL
 
  SELECT tc.nodeA, e.nodeB, tc.weight + e.weight, depth + 1, path || e.nodeB
  FROM g1_edges AS e, search_graph AS tc 
  WHERE e.nodeA = tc.nodeB AND e.nodeB <> ALL(path)
)
SELECT * FROM search_graph ORDER BY depth) AS temp WHERE nodeA = 'webbbr01' AND nodeB='clemero02' AND weight>=3) AS temp2;


--25--
CREATE VIEW g1_nodes(nodes) AS (SELECT DISTINCT playerID FROM (SELECT DISTINCT playerID FROM pitching) AS A UNION (SELECT DISTINCT playerID FROM allstarfull));
CREATE VIEW g1_edges(nodeA, nodeB, weight) AS (SELECT DISTINCT ON(playerIDA, playerIDB) playerIDA, playerIDB, count(yearIDA) AS weight FROM (WITH UPA(playerID, yearID, teamID) AS (SELECT * FROM (SELECT DISTINCT ON(playerID, yearID, teamID) playerID, yearID, teamID FROM pitching) AS A UNION ALL (SELECT DISTINCT ON(playerID, yearID, teamID) playerID, yearID, teamID FROM allstarfull WHERE GP=1)) SELECT A.playerID AS playerIDA, A.yearID AS yearIDA, A.teamID AS teamIDA, B.playerID AS playerIDB, B.yearID AS yearIDB, B.teamID AS teamIDB FROM UPA AS A, UPA AS B WHERE A.playerID != B.playerID AND A.yearID = B.yearID AND A.teamID = B.teamID) AS temp WHERE playerIDA != playerIDB AND yearIDA = yearIDB AND teamIDA = teamIDB GROUP BY playerIDA, playerIDB);
SELECT case when count(*)>0 then min(weight) else 0::integer end AS pathlength FROM (
SELECT DISTINCT * FROM (WITH RECURSIVE search_graph(nodeA, nodeB, weight, depth, path) AS 
( SELECT  nodeA, nodeB, weight AS path_length, 0, ARRAY[]::varchar[] || nodeA || nodeB AS path
  FROM g1_edges WHERE nodeA = 'garcifr02' 
 
  UNION ALL
 
  SELECT tc.nodeA, e.nodeB, tc.weight + e.weight, depth + 1, path || e.nodeB
  FROM g1_edges AS e, search_graph AS tc 
  WHERE e.nodeA = tc.nodeB AND e.nodeB <> ALL(path)
)
SELECT * FROM search_graph ORDER BY depth) AS temp WHERE nodeA = 'garcifr02' AND nodeB='leagubr01' ORDER BY weight ASC) AS temp2 GROUP BY nodeA;

--26--
CREATE VIEW g2_nodes(nodes) AS ((SELECT DISTINCT teamIDwinner FROM seriespost) UNION (SELECT DISTINCT teamIDloser FROM seriespost));
CREATE VIEW g2_edges(nodeA, nodeB) AS (SELECT DISTINCT ON (teamIDwinner, teamIDloser) teamIDwinner AS nodeA, teamIDloser AS nodeB FROM seriespost GROUP BY teamIDwinner, teamIDloser);
SELECT case when count(*)>0 then count(*) else 0::integer end AS count FROM (
SELECT DISTINCT * FROM (WITH RECURSIVE search_graph(nodeA, nodeB, weight, depth, path) AS 
( SELECT  nodeA, nodeB, 1 AS path_length, 0, ARRAY[]::varchar[] || nodeA || nodeB AS path
  FROM g2_edges WHERE nodeA = 'ARI' 
 
  UNION ALL
 
  SELECT tc.nodeA, e.nodeB, weight+1, depth + 1, path || e.nodeB
  FROM g2_edges AS e, search_graph AS tc 
  WHERE e.nodeA = tc.nodeB AND e.nodeB <> ALL(path)
)
SELECT * FROM search_graph ORDER BY depth) AS temp WHERE nodeA = 'ARI' AND nodeB='DET' ORDER BY weight ASC) AS temp2;

--27--
CREATE VIEW g2_nodes(nodes) AS ((SELECT DISTINCT teamIDwinner FROM seriespost) UNION (SELECT DISTINCT teamIDloser FROM seriespost));
CREATE VIEW g2_edges(nodeA, nodeB) AS (SELECT DISTINCT ON (teamIDwinner, teamIDloser) teamIDwinner AS nodeA, teamIDloser AS nodeB FROM seriespost GROUP BY teamIDwinner, teamIDloser);
SELECT nodeB AS teamid, max(weight) AS num_hops FROM (
SELECT DISTINCT * FROM (WITH RECURSIVE search_graph(nodeA, nodeB, weight, depth, path) AS 
( SELECT  nodeA, nodeB, 1 AS path_length, 0, ARRAY[]::varchar[] || nodeA || nodeB AS path
  FROM g2_edges WHERE nodeA = 'HOU' 
 
  UNION ALL
 
  SELECT tc.nodeA, e.nodeB, weight+1, depth + 1, path || e.nodeB
  FROM g2_edges AS e, search_graph AS tc 
  WHERE e.nodeA = tc.nodeB AND e.nodeB <> ALL(path) AND weight+1<=3
)
SELECT * FROM search_graph ORDER BY depth) AS temp WHERE nodeA = 'HOU' ORDER BY weight ASC) AS temp2 GROUP BY nodeB ORDER BY teamid ASC;

--28--
CREATE VIEW g2_nodes(nodes) AS ((SELECT DISTINCT teamIDwinner FROM seriespost) UNION (SELECT DISTINCT teamIDloser FROM seriespost));
CREATE VIEW g2_edges(nodeA, nodeB) AS (SELECT DISTINCT ON (teamIDwinner, teamIDloser) teamIDwinner AS nodeA, teamIDloser AS nodeB FROM seriespost GROUP BY teamIDwinner, teamIDloser);
SELECT B.teamID AS teamid, B.name AS teamname, path_length FROM teams AS B, (SELECT DISTINCT nodeB AS teamid, max(weight) AS path_length FROM (
SELECT DISTINCT * FROM (WITH RECURSIVE search_graph(nodeA, nodeB, weight, depth, path) AS 
( SELECT  nodeA, nodeB, 1 AS path_length, 0, ARRAY[]::varchar[] || nodeA || nodeB AS path
  FROM g2_edges WHERE nodeA = 'WS1' 
 
  UNION ALL
 
  SELECT tc.nodeA, e.nodeB, weight+1, depth + 1, path || e.nodeB
  FROM g2_edges AS e, search_graph AS tc 
  WHERE e.nodeA = tc.nodeB AND e.nodeB <> ALL(path)
)
SELECT * FROM search_graph ORDER BY depth) AS temp WHERE nodeA = 'WS1' ORDER BY weight DESC) AS temp2 GROUP BY nodeB HAVING max(weight)>(SELECT max(weight) AS path_length FROM (
SELECT DISTINCT * FROM (WITH RECURSIVE search_graph(nodeA, nodeB, weight, depth, path) AS 
( SELECT  nodeA, nodeB, 1 AS path_length, 0, ARRAY[]::varchar[] || nodeA || nodeB AS path
  FROM g2_edges WHERE nodeA = 'WS1' 
 
  UNION ALL
 
  SELECT tc.nodeA, e.nodeB, weight+1, depth + 1, path || e.nodeB
  FROM g2_edges AS e, search_graph AS tc 
  WHERE e.nodeA = tc.nodeB AND e.nodeB <> ALL(path)
)
SELECT * FROM search_graph ORDER BY depth) AS temp WHERE nodeA = 'WS1' ORDER BY weight DESC) AS temp2)) AS A WHERE A.teamid = B.teamID ORDER BY teamID ASC, teamname;





