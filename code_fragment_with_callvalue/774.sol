774.sol
function distributeExternal(uint256 _pID, uint256 _eth, uint256 _affID, FDDdatasets.EventReturns memory _eventData_) private returns(FDDdatasets.EventReturns) {
uint256 _com = _eth * 5 / 100;
uint256 _aff = _eth * 10 / 100;
if (_affID != _pID && plyr_[_affID].name != '') {
plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
emit FDDEvents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _pID, _aff, now);
} else {
_com += _aff;
if (!address(Bank).call.value(_com)(bytes4(keccak256("deposit()"))))  {  }
return(_eventData_);
function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, FDDdatasets.EventReturns memory _eventData_)  private  {
if (plyrRnds[_pID][_rID].keys == 0)
_eventData_ = managePlayer(_pID, _eventData_);
if (round[_rID].eth < 100000000000000000000 && plyrRnds[_pID][_rID].eth.add(_eth) > 10000000000000000000)  {
uint256 _availableLimit = (10000000000000000000).sub(plyrRnds[_pID][_rID].eth);
uint256 _refund = _eth.sub(_availableLimit);
plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
_eth = _availableLimit;
if (_eth > 1000000000)  {
uint256 _keys = (round[_rID].eth).keysRec(_eth);
if (_keys >= 1000000000000000000)   {
updateTimer(_keys, _rID);
if (round[_rID].plyr != _pID)
round[_rID].plyr = _pID;
_eventData_.compressedData = _eventData_.compressedData + 100;
if (_eth >= 100000000000000000)  {
airDropTracker_++;
if (airdrop() == true)  {
uint256 _prize;
if (_eth >= 10000000000000000000) {
_prize = ((airDropPot_).mul(75)) / 100;
plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
airDropPot_ = (airDropPot_).sub(_prize);
_eventData_.compressedData += 300000000000000000000000000000000;
} else if (_eth >= 1000000000000000000 && _eth < 10000000000000000000) {
_prize = ((airDropPot_).mul(50)) / 100;
plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
airDropPot_ = (airDropPot_).sub(_prize);
_eventData_.compressedData += 200000000000000000000000000000000;
} else if (_eth >= 100000000000000000 && _eth < 1000000000000000000) {
_prize = ((airDropPot_).mul(25)) / 100;
plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
airDropPot_ = (airDropPot_).sub(_prize);
_eventData_.compressedData += 100000000000000000000000000000000;
_eventData_.compressedData += 10000000000000000000000000000000;
_eventData_.compressedData += _prize * 1000000000000000000000000000000000;
airDropTracker_ = 0;
_eventData_.compressedData = _eventData_.compressedData + (airDropTracker_ * 1000);
plyrRnds[_pID][_rID].keys = _keys.add(plyrRnds[_pID][_rID].keys);
plyrRnds[_pID][_rID].eth = _eth.add(plyrRnds[_pID][_rID].eth);
round[_rID].keys = _keys.add(round[_rID].keys);
round[_rID].eth = _eth.add(round[_rID].eth);
_eventData_ = distributeExternal(_pID, _eth, _affID, _eventData_);
_eventData_ = distributeInternal(_rID, _pID, _eth, _keys, _eventData_);
endTx(_pID, _eth, _keys, _eventData_);
plyrRnds_[_pID] = plyrRnds[_pID][_rID];
round_ = round[_rID];
