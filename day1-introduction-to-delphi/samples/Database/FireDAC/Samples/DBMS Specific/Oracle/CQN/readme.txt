This project demonstrates Oracle >= 10.2 Continuous Query Notification (CQN) support.
To run the project:
1) Open Oracle_CQN.dpr project in RAD Studio IDE.
2) Click on the conOriginal.Params in Property Inspector and adjust connection parameters.
3) Run application.
4) Press "Open DB" button on top of the form. This will connect conOriginal/qOriginal,
then conChanges/qChanges and will start event alerter eaChanges.
5) Modify data in 1st grid (conOriginal/qOriginal) and see the changes in 2nd grid
(conChanges/qChanges). They appear there automatically by help of event alerter eaChanges.
The comboboxes above 2nd grid allows to choose different modes.
6) Buttons above 3d grid allows to bring into and control the changes in memory table 
mtRemote. "Merge using stream" check box allows to emulate remote data trnasfer.

Notes:
1) An Oracle user must have CHANGE NOTIFICATION privilege. For that execute command 
like this: GRANT CHANGE NOTIFICATION to FDDemo;
2) A SQL query, whos changes will be tracked, should:
* include ROWID column into SELECT list for a base table. Otherwise query will be 
refreshed in full instead of incrementally.
* be allowed to be included into inline SELECT, eg SELECT * FROM (<original query>).
3) TFDEventAlerter setup:
* Options.Kind must be set to QueryNotifies to use CQN.
* SubscriptionName must be not empty. Set it to any one value. Otherwise query will 
be refreshed in full instead of incrementally.
4) TFDEventAlerter must be activated before TFDQuery execution, because statement
must be registered with query notification API before execution.
5) With some OCI versions there is possible Access Violation on application exit, 
after TFDEventAlerter was activated, several notifications were received and 
TFDEventAlerter was deactivated.
