let player;
const RESOLVE_EMPTY = () => {};
let peroid = {
  timeout: null,
  resolve: RESOLVE_EMPTY,
  endAt: 0,
};

const checkPlayerPeroidAndSetTimeout = () => {
  const remainSeconds = peroid.endAt - player.getCurrentTime();
  const playing = player.getPlayerState() === 1;
  if (remainSeconds > 0 && playing) {
    peroid.timeout = setTimeout(() => {
      peroid.endAt = 0;
      peroid.resolve();
      peroid.timeout = null;
      peroid.resolve = RESOLVE_EMPTY;
    }, 1000 * remainSeconds)
  } else {
    clearTimeout(peroid.timeout)
  }
}

window.onYouTubeIframeAPIReady = () => {
  player = new YT.Player('player', {
    videoId: 'sNcvgpUqrwE',
    events: {
      onReady: () => {},
      onStateChange: checkPlayerPeroidAndSetTimeout,
    }
  });
}

const playPeroid = (startAt, seconds) => new Promise(r => {
  if (peroid.resolve === RESOLVE_EMPTY) {
    peroid.resolve = r;
    peroid.endAt = startAt + seconds;
    player.seekTo(startAt);
    player.playVideo();
    checkPlayerPeroidAndSetTimeout();
  }
});

const wait = seconds => new Promise(r => {
  player.pauseVideo()
  setTimeout(r, seconds * 1000)
})

const playPeroidAndStop = async (startAt, seconds) => {
  await playPeroid(startAt, seconds)
  player.pauseVideo()
}

window.sayNiHao = async () => {
  await playPeroid(471.75, 0.50);
  await playPeroidAndStop(829.00, 0.75);
}

window.addEventListener('DOMContentLoaded', () => {
  const input = document.getElementById('text');

  document.getElementById('speak').addEventListener('click', async () => {
    const request = await fetch(`/api/sounds?text=${encodeURI(input.value)}`);
    const { sounds } = await request.json();
    if (sounds) {
      for (const sound of sounds) {
        if (sound.start && sound.seconds) {
          await playPeroid(parseFloat(sound.start), sound.seconds);
        } else {
          await wait(0.5);
        }
      }
      player.pauseVideo();
    }
  });
});
