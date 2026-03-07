const EMOJI_CATEGORIES = {
  Rituals: ['🕉️', '🪔', '🔥', '🛕', '🔔', '🥥', '🔱', '🐚', '📖'],
  Family: ['🎂', '💍', '🏠', '🎁', '👨‍👩‍👧', '👵', '👴', '👶'],
  Food: ['🍚', '🍲', '🍎', '🥦', '🥕', '🍇', '🍗', '🥘', '🌽'],
  Activity: ['🏃', '✈️', '🎵', '🚴', '🚗', '🚶', '🏸', '🏊']
};

const IconPickerModal = ({ selected, onSelect, onClose }) => {
  const [tab, setTab] = useState('Rituals');

  return (
    <div className="fixed inset-0 bg-black/50 flex items-end sm:items-center justify-center z-50">
      <div className="bg-white w-full max-w-md rounded-t-3xl sm:rounded-3xl p-6 h-[70vh]">
        <div className="flex justify-between mb-4">
          <h3 className="font-bold">Select Event Icon</h3>
          <button onClick={onClose} className="text-orange-500 font-bold">Done</button>
        </div>

        {/* Tabs */}
        <div className="flex overflow-x-auto gap-4 mb-6 no-scrollbar">
          {Object.keys(EMOJI_CATEGORIES).map(cat => (
            <button 
              key={cat}
              onClick={() => setTab(cat)}
              className={`pb-2 whitespace-nowrap ${tab === cat ? 'border-b-2 border-orange-500 text-orange-600' : 'text-gray-400'}`}
            >
              {cat}
            </button>
          ))}
        </div>

        {/* Icon Grid */}
        <div className="grid grid-cols-4 gap-6 overflow-y-auto h-full pb-20">
          {EMOJI_CATEGORIES[tab].map(emoji => (
            <button 
              key={emoji}
              onClick={() => onSelect(emoji)}
              className={`text-4xl p-2 rounded-xl transition ${selected === emoji ? 'bg-orange-100 scale-110' : ''}`}
            >
              {emoji}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};
export default IconPickerModal;