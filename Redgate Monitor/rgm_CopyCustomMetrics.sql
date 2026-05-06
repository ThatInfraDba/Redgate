/*
Created by: Danny de Haan
Created on: 2026-05-06
Version: 1.3

Description:
This script generates an insert script to migrate custom metrics and related alert configurations from one Redgate Monitor Base Monitor database to another. 
It extracts data from various configuration tables, formats it into VALUES clauses for INSERT statements, 
and assembles a complete script that can be executed on the target database to recreate the custom metrics and alert configurations.
Custom Metrics that were assigned to specific groups will be assigned to the "All servers" instances group in the target database, as groups might not match between source and target.

Readme:
- Run this on the SOURCE database to generate an insert script for the TARGET database.
- Copy the output from the Messages tab and run it on the TARGET database.
- Make sure not to copy the completion time of the script! 

*/
SET NOCOUNT ON;

DECLARE @Script NVARCHAR(MAX) = N'';
DECLARE @MetricValues NVARCHAR(MAX) = N'';
DECLARE @AlertDefValues NVARCHAR(MAX) = N'';
DECLARE @AlertConfigValues NVARCHAR(MAX) = N'';
DECLARE @GroupAlertConfigValues NVARCHAR(MAX) = N'';
DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10);

-- 1) Build VALUES for settings.CustomMetrics
SELECT @MetricValues = @MetricValues +
    CASE WHEN @MetricValues <> N'' THEN N',' + @CRLF ELSE N'' END +
    N'    (' +
        CAST(cm.Id AS NVARCHAR(20)) + N', ' +
        N'N''' + REPLACE(cm.Name, '''', '''''') + N''', ' +
        N'N''' + REPLACE(ISNULL(cm.Description, N''), '''', '''''') + N''', ' +
        N'N''' + REPLACE(cm.Tsql, '''', '''''') + N''', ' +
        CAST(cm.Frequency AS NVARCHAR(20)) + N', ' +
        CAST(cm.UseRateOfChange AS NVARCHAR(1)) + N', ' +
        CAST(cm.Multiplier AS NVARCHAR(50)) + N', ' +
        CAST(cm.Status AS NVARCHAR(5)) + N', ' +
        N'N''' + REPLACE(CAST(cm.Databases AS NVARCHAR(MAX)), '''', '''''') + N''', ' +
        CAST(cm.DatabaseSelectionMode AS NVARCHAR(5)) + N', ' +
        N'N''' + REPLACE(ISNULL(cm.SampleTime, N''), '''', '''''') + N''', ' +
        CAST(cm.TargetEntityType AS NVARCHAR(5)) + N', ' +
        CASE WHEN cm.AlertDetailQuery IS NULL THEN N'NULL'
             ELSE N'N''' + REPLACE(cm.AlertDetailQuery, '''', '''''') + N'''' END +
    N')'
FROM settings.CustomMetrics cm
ORDER BY cm.Id;

-- 2) Build VALUES for settings.CustomAlertDefinitions
SELECT @AlertDefValues = @AlertDefValues +
    CASE WHEN @AlertDefValues <> N'' THEN N',' + @CRLF ELSE N'' END +
    N'    (' +
        CAST(cad.Id AS NVARCHAR(20)) + N', ' +
        N'N''' + REPLACE(cad.Name, '''', '''''') + N''', ' +
        N'N''' + REPLACE(ISNULL(cad.Description, N''), '''', '''''') + N''', ' +
        CAST(cad.CustomMetricId AS NVARCHAR(20)) + N', ' +
        CAST(cad.Direction AS NVARCHAR(10)) +
    N')'
FROM settings.CustomAlertDefinitions cad
ORDER BY cad.Id;

-- 3) Build VALUES for config.AlertConfiguration (WHERE _AlertType = 40)
SELECT @AlertConfigValues = @AlertConfigValues +
    CASE WHEN @AlertConfigValues <> N'' THEN N',' + @CRLF ELSE N'' END +
    N'    (' +
        CAST(ac._SubType AS NVARCHAR(20)) + N', ' +
        N'N''' + REPLACE(CAST(ac._Configuration AS NVARCHAR(MAX)), '''', '''''') + N''', ' +
        CAST(ac._Enabled AS NVARCHAR(1)) + N', ' +
        CAST(ac._AlertNotification AS NVARCHAR(20)) + N', ' +
        N'N''' + REPLACE(ac._EmailAddress, '''', '''''') + N''', ' +
        N'N''' + REPLACE(ac._Comments, '''', '''''') + N''', ' +
        CAST(ac._Version AS NVARCHAR(20)) + N', ' +
        CAST(ac._SlackEnabled AS NVARCHAR(1)) + N', ' +
        CAST(ac._SnmpEnabled AS NVARCHAR(1)) + N', ' +
        CAST(ac._WebhookEnabled AS NVARCHAR(1)) + N', ' +
        CAST(ac._ScriptEnabled AS NVARCHAR(1)) + N', ' +
        CAST(ac._ServiceNowEnabled AS NVARCHAR(1)) + N', ' +
        CAST(ac._MsTeamsEnabled AS NVARCHAR(1)) + N', ' +
        N'N''' + REPLACE(ac._GenericCustomEmailText, '''', '''''') + N''', ' +
        N'N''' + REPLACE(ac._LowSeverityCustomEmailText, '''', '''''') + N''', ' +
        N'N''' + REPLACE(ac._MediumSeverityCustomEmailText, '''', '''''') + N''', ' +
        N'N''' + REPLACE(ac._HighSeverityCustomEmailText, '''', '''''') + N'''' +
    N')'
FROM config.AlertConfiguration ac
WHERE ac._AlertType = 40
ORDER BY ac._SubType;

-- 4) Build VALUES for config.Group_AlertConfiguration (WHERE _AlertType = 40)
SELECT @GroupAlertConfigValues = @GroupAlertConfigValues +
    CASE WHEN @GroupAlertConfigValues <> N'' THEN N',' + @CRLF ELSE N'' END +
    N'    (' +
        CAST(gac.Id AS NVARCHAR(20)) + N', ' +
        CAST(gac._SubType AS NVARCHAR(20)) + N', ' +
        N'N''' + REPLACE(CAST(gac._Configuration AS NVARCHAR(MAX)), '''', '''''') + N''', ' +
        CAST(gac._Enabled AS NVARCHAR(1)) + N', ' +
        CAST(gac._AlertNotification AS NVARCHAR(20)) + N', ' +
        N'N''' + REPLACE(gac._EmailAddress, '''', '''''') + N''', ' +
        N'N''' + REPLACE(gac._Comments, '''', '''''') + N''', ' +
        CAST(gac._Version AS NVARCHAR(20)) + N', ' +
        CAST(gac._SlackEnabled AS NVARCHAR(1)) + N', ' +
        CAST(gac._SnmpEnabled AS NVARCHAR(1)) + N', ' +
        CAST(gac._WebhookEnabled AS NVARCHAR(1)) + N', ' +
        CAST(gac._ScriptEnabled AS NVARCHAR(1)) + N', ' +
        CAST(gac._ServiceNowEnabled AS NVARCHAR(1)) + N', ' +
        CAST(gac._MsTeamsEnabled AS NVARCHAR(1)) + N', ' +
        N'N''' + REPLACE(gac._GenericCustomEmailText, '''', '''''') + N''', ' +
        N'N''' + REPLACE(gac._LowSeverityCustomEmailText, '''', '''''') + N''', ' +
        N'N''' + REPLACE(gac._MediumSeverityCustomEmailText, '''', '''''') + N''', ' +
        N'N''' + REPLACE(gac._HighSeverityCustomEmailText, '''', '''''') + N'''' +
    N')'
FROM config.Group_AlertConfiguration gac
WHERE gac._AlertType = 40
ORDER BY gac.Id, gac._SubType;

-------------------------------------------------------------------
-- Assemble the target script
-------------------------------------------------------------------
SET @Script =
N'-- Generated insert script - run this on the TARGET database' + @CRLF + 
N'-- Make sure to restart the Redgate Monitor base monitor service after the insert' + @CRLF +
N'-- Do NOT copy the Completion Time from the messages screen as part of the script' + @CRLF + @CRLF +

-- Mapping tables
N'DECLARE @NewMetricIDs TABLE (OriginalMetricID BIGINT, NewMetricID BIGINT);' + @CRLF +
N'DECLARE @NewAlertDefIDs TABLE (OriginalAlertDefID BIGINT, NewAlertDefID BIGINT);' + @CRLF + @CRLF +

-- Source data: CustomMetrics
N'DECLARE @SourceMetrics TABLE (' + @CRLF +
N'    OriginalMetricId BIGINT, Name NVARCHAR(255), Description NVARCHAR(MAX),' + @CRLF +
N'    Tsql NVARCHAR(MAX), Frequency BIGINT, UseRateOfChange BIT, Multiplier FLOAT,' + @CRLF +
N'    Status TINYINT, Databases NVARCHAR(MAX), DatabaseSelectionMode TINYINT,' + @CRLF +
N'    SampleTime NVARCHAR(10), TargetEntityType TINYINT, AlertDetailQuery NVARCHAR(MAX)' + @CRLF +
N');' + @CRLF + @CRLF +
N'INSERT INTO @SourceMetrics VALUES' + @CRLF +
@MetricValues + N';' + @CRLF + @CRLF +

-- Source data: CustomAlertDefinitions
N'DECLARE @SourceAlertDefs TABLE (' + @CRLF +
N'    OriginalAlertDefId BIGINT, Name NVARCHAR(255), Description NVARCHAR(MAX),' + @CRLF +
N'    OldCustomMetricId BIGINT, Direction INT' + @CRLF +
N');' + @CRLF + @CRLF +
N'INSERT INTO @SourceAlertDefs VALUES' + @CRLF +
@AlertDefValues + N';' + @CRLF + @CRLF +

-- Cursor 1: Insert CustomMetrics row by row
N'-- Insert CustomMetrics row by row to capture identity mapping' + @CRLF +
N'DECLARE @OrigId BIGINT, @Name NVARCHAR(255), @Desc NVARCHAR(MAX), @Tsql NVARCHAR(MAX),' + @CRLF +
N'        @Freq BIGINT, @UseRoC BIT, @Mult FLOAT, @Stat TINYINT, @Dbs NVARCHAR(MAX),' + @CRLF +
N'        @DbSelMode TINYINT, @SampleT NVARCHAR(10), @TargetET TINYINT, @AlertDQ NVARCHAR(MAX);' + @CRLF + @CRLF +
N'DECLARE MetricCursor CURSOR LOCAL FAST_FORWARD FOR' + @CRLF +
N'    SELECT OriginalMetricId, Name, Description, Tsql, Frequency, UseRateOfChange, Multiplier,' + @CRLF +
N'           Status, Databases, DatabaseSelectionMode, SampleTime, TargetEntityType, AlertDetailQuery' + @CRLF +
N'    FROM @SourceMetrics ORDER BY OriginalMetricId;' + @CRLF + @CRLF +
N'OPEN MetricCursor;' + @CRLF +
N'FETCH NEXT FROM MetricCursor INTO @OrigId, @Name, @Desc, @Tsql, @Freq, @UseRoC, @Mult,' + @CRLF +
N'    @Stat, @Dbs, @DbSelMode, @SampleT, @TargetET, @AlertDQ;' + @CRLF + @CRLF +
N'WHILE @@FETCH_STATUS = 0' + @CRLF +
N'BEGIN' + @CRLF +
N'    INSERT INTO settings.CustomMetrics (Name, Description, Tsql, Frequency, UseRateOfChange, Multiplier, Status, Databases, DatabaseSelectionMode, SampleTime, TargetEntityType, AlertDetailQuery)' + @CRLF +
N'    VALUES (@Name, @Desc, @Tsql, @Freq, @UseRoC, @Mult, @Stat, CAST(@Dbs AS XML), @DbSelMode, @SampleT, @TargetET, @AlertDQ);' + @CRLF +
N'    INSERT INTO @NewMetricIDs (OriginalMetricID, NewMetricID) VALUES (@OrigId, SCOPE_IDENTITY());' + @CRLF +
N'    FETCH NEXT FROM MetricCursor INTO @OrigId, @Name, @Desc, @Tsql, @Freq, @UseRoC, @Mult,' + @CRLF +
N'        @Stat, @Dbs, @DbSelMode, @SampleT, @TargetET, @AlertDQ;' + @CRLF +
N'END' + @CRLF +
N'CLOSE MetricCursor; DEALLOCATE MetricCursor;' + @CRLF + @CRLF +

-- Insert CustomMetricGroups for each new metric (GroupId = NULL)
N'-- Insert CustomMetricGroups for each new metric (GroupId = NULL since groups may differ)' + @CRLF +
N'INSERT INTO settings.CustomMetricGroups (CustomMetricId, GroupId)' + @CRLF +
N'SELECT NewMetricID, NULL' + @CRLF +
N'FROM @NewMetricIDs;' + @CRLF + @CRLF +

-- Cursor 2: Insert CustomAlertDefinitions row by row
N'-- Insert CustomAlertDefinitions row by row to capture identity mapping' + @CRLF +
N'DECLARE @OldADId BIGINT, @ADName NVARCHAR(255), @ADDesc NVARCHAR(MAX), @OldCMId BIGINT, @Dir INT;' + @CRLF + @CRLF +
N'DECLARE AlertDefCursor CURSOR LOCAL FAST_FORWARD FOR' + @CRLF +
N'    SELECT OriginalAlertDefId, Name, Description, OldCustomMetricId, Direction' + @CRLF +
N'    FROM @SourceAlertDefs ORDER BY OriginalAlertDefId;' + @CRLF + @CRLF +
N'OPEN AlertDefCursor;' + @CRLF +
N'FETCH NEXT FROM AlertDefCursor INTO @OldADId, @ADName, @ADDesc, @OldCMId, @Dir;' + @CRLF + @CRLF +
N'WHILE @@FETCH_STATUS = 0' + @CRLF +
N'BEGIN' + @CRLF +
N'    DECLARE @NewCMId BIGINT;' + @CRLF +
N'    SELECT @NewCMId = NewMetricID FROM @NewMetricIDs WHERE OriginalMetricID = @OldCMId;' + @CRLF +
N'    INSERT INTO settings.CustomAlertDefinitions (Name, Description, CustomMetricId, Direction)' + @CRLF +
N'    VALUES (@ADName, @ADDesc, @NewCMId, @Dir);' + @CRLF +
N'    INSERT INTO @NewAlertDefIDs (OriginalAlertDefID, NewAlertDefID) VALUES (@OldADId, SCOPE_IDENTITY());' + @CRLF +
N'    FETCH NEXT FROM AlertDefCursor INTO @OldADId, @ADName, @ADDesc, @OldCMId, @Dir;' + @CRLF +
N'END' + @CRLF +
N'CLOSE AlertDefCursor; DEALLOCATE AlertDefCursor;' + @CRLF + @CRLF;

-- 3) AlertConfiguration insert (if data exists)
IF @AlertConfigValues <> N''
BEGIN
    SET @Script = @Script +
    N'-- Insert config.AlertConfiguration (remapping _SubType via alert definition ID mapping)' + @CRLF +
    N'INSERT INTO config.AlertConfiguration (_AlertType, _SubType, _Configuration, _Enabled, _AlertNotification,' + @CRLF +
    N'    _EmailAddress, _Comments, _Version, _SlackEnabled, _SnmpEnabled, _WebhookEnabled,' + @CRLF +
    N'    _ScriptEnabled, _ServiceNowEnabled, _MsTeamsEnabled,' + @CRLF +
    N'    _GenericCustomEmailText, _LowSeverityCustomEmailText, _MediumSeverityCustomEmailText, _HighSeverityCustomEmailText)' + @CRLF +
    N'SELECT 40, n.NewAlertDefID, CAST(src._Configuration AS XML), src._Enabled, src._AlertNotification,' + @CRLF +
    N'    src._EmailAddress, src._Comments, src._Version, src._SlackEnabled, src._SnmpEnabled, src._WebhookEnabled,' + @CRLF +
    N'    src._ScriptEnabled, src._ServiceNowEnabled, src._MsTeamsEnabled,' + @CRLF +
    N'    src._GenericCustomEmailText, src._LowSeverityCustomEmailText, src._MediumSeverityCustomEmailText, src._HighSeverityCustomEmailText' + @CRLF +
    N'FROM (' + @CRLF +
    N'    VALUES' + @CRLF +
    @AlertConfigValues + @CRLF +
    N') AS src (OldSubType, _Configuration, _Enabled, _AlertNotification, _EmailAddress, _Comments, _Version,' + @CRLF +
    N'    _SlackEnabled, _SnmpEnabled, _WebhookEnabled, _ScriptEnabled, _ServiceNowEnabled, _MsTeamsEnabled,' + @CRLF +
    N'    _GenericCustomEmailText, _LowSeverityCustomEmailText, _MediumSeverityCustomEmailText, _HighSeverityCustomEmailText)' + @CRLF +
    N'INNER JOIN @NewAlertDefIDs n ON src.OldSubType = n.OriginalAlertDefID;' + @CRLF + @CRLF;
END

-- 4) Group_AlertConfiguration insert (if data exists)
IF @GroupAlertConfigValues <> N''
BEGIN
    SET @Script = @Script +
    N'-- Insert config.Group_AlertConfiguration (remapping _SubType via alert definition ID mapping)' + @CRLF +
    N'INSERT INTO config.Group_AlertConfiguration (Id, _AlertType, _SubType, _Configuration, _Enabled, _AlertNotification,' + @CRLF +
    N'    _EmailAddress, _Comments, _Version, _SlackEnabled, _SnmpEnabled, _WebhookEnabled,' + @CRLF +
    N'    _ScriptEnabled, _ServiceNowEnabled, _MsTeamsEnabled,' + @CRLF +
    N'    _GenericCustomEmailText, _LowSeverityCustomEmailText, _MediumSeverityCustomEmailText, _HighSeverityCustomEmailText)' + @CRLF +
    N'SELECT src.GroupId, 40, n.NewAlertDefID, CAST(src._Configuration AS XML), src._Enabled, src._AlertNotification,' + @CRLF +
    N'    src._EmailAddress, src._Comments, src._Version, src._SlackEnabled, src._SnmpEnabled, src._WebhookEnabled,' + @CRLF +
    N'    src._ScriptEnabled, src._ServiceNowEnabled, src._MsTeamsEnabled,' + @CRLF +
    N'    src._GenericCustomEmailText, src._LowSeverityCustomEmailText, src._MediumSeverityCustomEmailText, src._HighSeverityCustomEmailText' + @CRLF +
    N'FROM (' + @CRLF +
    N'    VALUES' + @CRLF +
    @GroupAlertConfigValues + @CRLF +
    N') AS src (GroupId, OldSubType, _Configuration, _Enabled, _AlertNotification, _EmailAddress, _Comments, _Version,' + @CRLF +
    N'    _SlackEnabled, _SnmpEnabled, _WebhookEnabled, _ScriptEnabled, _ServiceNowEnabled, _MsTeamsEnabled,' + @CRLF +
    N'    _GenericCustomEmailText, _LowSeverityCustomEmailText, _MediumSeverityCustomEmailText, _HighSeverityCustomEmailText)' + @CRLF +
    N'INNER JOIN @NewAlertDefIDs n ON src.OldSubType = n.OriginalAlertDefID;' + @CRLF + @CRLF;
END

-- Line-by-line PRINT to avoid truncation
DECLARE @LineEnd INT;
DECLARE @Line NVARCHAR(MAX);

WHILE LEN(@Script) > 0
BEGIN
    SET @LineEnd = CHARINDEX(@CRLF, @Script);
    IF @LineEnd > 0
    BEGIN
        SET @Line = LEFT(@Script, @LineEnd - 1);
        SET @Script = SUBSTRING(@Script, @LineEnd + 2, LEN(@Script));
    END
    ELSE
    BEGIN
        SET @Line = @Script;
        SET @Script = N'';
    END
    PRINT @Line;
END
