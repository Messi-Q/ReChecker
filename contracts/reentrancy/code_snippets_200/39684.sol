39684.sol
function () payable {
if (msg.data.length > 0) {
createSeries(msg.data, 0, "", "", 0x0);
} else if (latestSeriesForUser[msg.sender] != 0) {
if (latestSeriesForUser[msg.sender].call.value(msg.value)())
DepositMade(latestSeriesForUser[msg.sender], msg.value);
} else {
createSeries("", 0, "", "", 0x0);
contract SeriesFactory {
address public seriesFactory;
address public owner;
