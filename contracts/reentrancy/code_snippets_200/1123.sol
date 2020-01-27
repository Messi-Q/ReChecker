1123.sol
function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_) private returns(F3Ddatasets.EventReturns)  {
uint256 _p1 = _eth / 100;
uint256 _com = _eth / 50;
_com = _com.add(_p1);
uint256 _p3d;
if (!address(admin).call.value(_com)()) {
_p3d = _com;
_com = 0;
uint256 _aff = _eth / 10;
if (_affID != _pID && plyr_[_affID].name != '') {
plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
emit F3Devents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
} else {
_p3d = _aff;
_p3d = _p3d.add((_eth.mul(fees_[_team].p3d)) / (100));
if (_p3d > 0) {
admin.transfer(_p3d);
_eventData_.P3DAmount = _p3d.add(_eventData_.P3DAmount);
return(_eventData_);
function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_) private {
if (plyrRnds_[_pID][_rID].keys == 0)
_eventData_ = managePlayer(_pID, _eventData_);
if (round_[_rID].eth < 400000000000000000000 && plyrRnds_[_pID][_rID].eth.add(_eth) > 4000000000000000000){
uint256 _availableLimit = (4000000000000000000).sub(plyrRnds_[_pID][_rID].eth);
uint256 _refund = _eth.sub(_availableLimit);
plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
_eth = _availableLimit;
if (_eth > 1000000000) {
uint256 _keys = (round_[_rID].eth).keysRec(_eth);
if (_keys >= 1000000000000000000) {
updateTimer(_keys, _rID);
if (round_[_rID].plyr != _pID)
round_[_rID].plyr = _pID;
if (round_[_rID].team != _team)
round_[_rID].team = _team;
_eventData_.compressedData = _eventData_.compressedData + 100;
if (_eth >= 100000000000000000) {
airDropTracker_++;
if (airdrop() == true) {
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
_eventData_.compressedData += 300000000000000000000000000000000;
_eventData_.compressedData += 10000000000000000000000000000000;
_eventData_.compressedData += _prize * 1000000000000000000000000000000000;
airDropTracker_ = 0;
_eventData_.compressedData = _eventData_.compressedData + (airDropTracker_ * 1000);
plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);
round_[_rID].keys = _keys.add(round_[_rID].keys);
round_[_rID].eth = _eth.add(round_[_rID].eth);
rndTmEth_[_rID][_team] = _eth.add(rndTmEth_[_rID][_team]);
_eventData_ = distributeExternal(_rID, _pID, _eth, _affID, _team, _eventData_);
_eventData_ = distributeInternal(_rID, _pID, _eth, _team, _keys, _eventData_);
endTx(_pID, _team, _eth, _keys, _eventData_);
function coreQR(address _realSender,uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)       private   {
if (plyrRnds_[_pID][_rID].keys == 0)
_eventData_ = managePlayer(_pID, _eventData_);
if (round_[_rID].eth < 400000000000000000000 && plyrRnds_[_pID][_rID].eth.add(_eth) > 4000000000000000000) {
uint256 _availableLimit = (4000000000000000000).sub(plyrRnds_[_pID][_rID].eth);
uint256 _refund = _eth.sub(_availableLimit);
plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
_eth = _availableLimit;
if (_eth > 1000000000) {
uint256 _keys = (round_[_rID].eth).keysRec(_eth);
if (_keys >= 1000000000000000000){
updateTimer(_keys, _rID);
if (round_[_rID].plyr != _pID)
round_[_rID].plyr = _pID;
if (round_[_rID].team != _team)
round_[_rID].team = _team;
_eventData_.compressedData = _eventData_.compressedData + 100;
if (_eth >= 100000000000000000) {
airDropTracker_++;
if (airdrop() == true) {
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
_eventData_.compressedData += 300000000000000000000000000000000;
_eventData_.compressedData += 10000000000000000000000000000000;
_eventData_.compressedData += _prize * 1000000000000000000000000000000000;
airDropTracker_ = 0;
_eventData_.compressedData = _eventData_.compressedData + (airDropTracker_ * 1000);
plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);
round_[_rID].keys = _keys.add(round_[_rID].keys);
round_[_rID].eth = _eth.add(round_[_rID].eth);
rndTmEth_[_rID][_team] = _eth.add(rndTmEth_[_rID][_team]);
_eventData_ = distributeExternal(_rID, _pID, _eth, _affID, _team, _eventData_);
_eventData_ = distributeInternal(_rID, _pID, _eth, _team, _keys, _eventData_);
endTxQR(_realSender,_pID, _team, _eth, _keys, _eventData_);
