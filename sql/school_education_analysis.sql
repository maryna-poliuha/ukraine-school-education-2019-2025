SELECT region, "year", schools, students
FROM school_education;


-- SQL 1. Динаміка шкільної освіти України за 2019–2025 роки
-- Мета: подивитися, як щороку змінювалася кількість шкіл та учнів.
-- Беремо лише загальнодержавні показники, без окремих областей.

SELECT
    "year",
    schools,
    students
FROM school_education
WHERE region = 'Україна'
ORDER BY "year";


-- SQL 2. Загальна зміна кількості шкіл та учнів за 2019–2025 роки
-- Порівнюємо початковий (2019) та кінцевий (2025) роки.
-- Розраховуємо абсолютну зміну та зміну у відсотках.

SELECT
    a.schools AS schools_2019,
    b.schools AS schools_2025,
    b.schools - a.schools AS schools_change,
    ROUND((b.schools - a.schools) * 100.0 / a.schools, 2) AS schools_change_pct,

    a.students AS students_2019,
    b.students AS students_2025,
    b.students - a.students AS students_change,
    ROUND((b.students - a.students) * 100.0 / a.students, 2) AS students_change_pct

FROM school_education AS a
JOIN school_education AS b
    ON a.region = b.region
WHERE a.region = 'Україна'
  AND a."year" = 2019
  AND b."year" = 2025;


-- SQL 3. Регіони з найбільшим скороченням
-- облікованої кількості шкіл у 2019–2025 роках.
-- Важливо: скорочення показника не обов'язково
-- означає фізичне закриття шкіл.

SELECT
    a.region,
    a.schools AS schools_2019,
    b.schools AS schools_2025,
    b.schools - a.schools AS schools_change,
    ROUND(
        (b.schools - a.schools) * 100.0 / a.schools,
        2
    ) AS schools_change_pct

FROM school_education AS a
JOIN school_education AS b
    ON a.region = b.region

WHERE a."year" = 2019
  AND b."year" = 2025
  AND a.region <> 'Україна'

ORDER BY schools_change_pct ASC;




-- SQL 4. Зміна облікованої кількості учнів за регіонами у 2019–2025 роках
-- Порівнюємо кількість учнів у 2019 та 2025 роках.
-- Розраховуємо абсолютну та відсоткову зміну.
-- Сортуємо регіони від найбільшого скорочення у відсотках.
-- Важливо: результати показують, де змінилася кількість учнів,
-- але не пояснюють причин цих змін (наприклад, міграції).
-- На порівнянність даних могло вплинути статистичне охоплення територій.

SELECT
    a.region,
    a.students AS students_2019,
    b.students AS students_2025,
    b.students - a.students AS students_change,
    ROUND((b.students - a.students) * 100.0 / a.students, 2) AS students_change_pct

FROM school_education AS a
JOIN school_education AS b
    ON a.region = b.region

WHERE a."year" = 2019
  AND b."year" = 2025
  AND a.region <> 'Україна'

ORDER BY students_change_pct ASC;




-- SQL 5. Кількість учнів у розрахунку на одну школу в Україні за 2019–2025 роки
-- Ділимо загальну кількість учнів на загальну кількість шкіл.
-- Аналізуємо зміну цього співвідношення за роками.
-- Важливо: показник не відображає фактичну наповненість шкіл
-- і не дозволяє робити висновки про їх переповненість.
-- Дані можуть бути не зовсім порівнюваними, бо в різні роки
-- могли враховувати школи та учнів із різних територій.

SELECT
    "year",
    schools,
    students,
    ROUND(students * 1.0 / NULLIF(schools, 0), 2) AS students_per_school

FROM school_education
WHERE region = 'Україна'
ORDER BY "year";


-- SQL 6. Щорічна зміна кількості шкіл та учнів у 2019–2025 роках
-- Порівнюємо кожен рік із попереднім.
-- Розраховуємо зміну кількості шкіл та учнів у відсотках.
-- Важливо: результати показують зміни, але не їх причини.

SELECT
    "year",
    schools,
    students,

    ROUND(
        (schools - LAG(schools) OVER (ORDER BY "year"))
        * 100.0 / LAG(schools) OVER (ORDER BY "year"),
        2
    ) AS schools_change_pct,

    ROUND(
        (students - LAG(students) OVER (ORDER BY "year"))
        * 100.0 / LAG(students) OVER (ORDER BY "year"),
        2
    ) AS students_change_pct

FROM school_education
WHERE region = 'Україна'
ORDER BY "year";



-- SQL 7. Перевірка загальнодержавних і регіональних даних
-- Підсумовуємо показники всіх регіонів за кожен рік.
-- Порівнюємо їх із загальнодержавними показниками.
-- Різниця 0 означає, що суми збігаються.

SELECT
    a."year",
    a.schools AS schools_ukraine,
    b.schools_sum,
    a.schools - b.schools_sum AS schools_difference,

    a.students AS students_ukraine,
    b.students_sum,
    a.students - b.students_sum AS students_difference

FROM school_education AS a

JOIN (
    SELECT
        "year",
        SUM(schools) AS schools_sum,
        SUM(students) AS students_sum
    FROM school_education
    WHERE region <> 'Україна'
    GROUP BY "year"
) AS b
    ON a."year" = b."year"

WHERE a.region = 'Україна'
ORDER BY a."year";
