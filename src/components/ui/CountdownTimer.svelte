<script lang="ts">
  interface TimeLeft {
    days: number;
    hours: number;
    minutes: number;
    seconds: number;
  }

  // Target: End of this Sunday (February 8, 2026 at 23:59:59)
  const targetDate = new Date('2026-02-08T23:59:59');

  let timeLeft = $state<TimeLeft>({ days: 0, hours: 0, minutes: 0, seconds: 0 });
  let expired = $state(false);

  function calculateTimeLeft(): TimeLeft {
    const now = new Date();
    const difference = targetDate.getTime() - now.getTime();

    if (difference <= 0) {
      expired = true;
      return { days: 0, hours: 0, minutes: 0, seconds: 0 };
    }

    return {
      days: Math.floor(difference / (1000 * 60 * 60 * 24)),
      hours: Math.floor((difference / (1000 * 60 * 60)) % 24),
      minutes: Math.floor((difference / 1000 / 60) % 60),
      seconds: Math.floor((difference / 1000) % 60),
    };
  }

  function pad(n: number): string {
    return n.toString().padStart(2, '0');
  }

  $effect(() => {
    timeLeft = calculateTimeLeft();
    const interval = setInterval(() => {
      timeLeft = calculateTimeLeft();
    }, 1000);

    return () => clearInterval(interval);
  });
</script>

<div class="countdown-banner">
  <div class="countdown-content">
    <div class="countdown-label">
      <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <span>Alpha pricing ends in</span>
    </div>
    {#if expired}
      <div class="countdown-expired">Alpha pricing has ended</div>
    {:else}
      <div class="countdown-timer">
        <div class="time-block">
          <span class="time-value">{timeLeft.days}</span>
          <span class="time-label">days</span>
        </div>
        <span class="time-separator">:</span>
        <div class="time-block">
          <span class="time-value">{pad(timeLeft.hours)}</span>
          <span class="time-label">hrs</span>
        </div>
        <span class="time-separator">:</span>
        <div class="time-block">
          <span class="time-value">{pad(timeLeft.minutes)}</span>
          <span class="time-label">min</span>
        </div>
        <span class="time-separator">:</span>
        <div class="time-block">
          <span class="time-value">{pad(timeLeft.seconds)}</span>
          <span class="time-label">sec</span>
        </div>
      </div>
    {/if}
  </div>
</div>

<style>
  .countdown-banner {
    background: linear-gradient(135deg, rgba(169, 216, 13, 0.15) 0%, rgba(169, 216, 13, 0.05) 100%);
    border: 1px solid rgba(169, 216, 13, 0.3);
    border-radius: 1rem;
    padding: 1rem 1.5rem;
    margin-bottom: 1.5rem;
  }

  .countdown-content {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.75rem;
  }

  @media (min-width: 640px) {
    .countdown-content {
      flex-direction: row;
      justify-content: center;
      gap: 1.5rem;
    }
  }

  .countdown-label {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    color: #a9d80d;
    font-weight: 600;
    font-size: 0.875rem;
  }

  .countdown-timer {
    display: flex;
    align-items: center;
    gap: 0.25rem;
  }

  .time-block {
    display: flex;
    flex-direction: column;
    align-items: center;
    min-width: 3rem;
  }

  .time-value {
    font-size: 1.5rem;
    font-weight: 700;
    color: #e8eeef;
    font-variant-numeric: tabular-nums;
    line-height: 1;
  }

  .time-label {
    font-size: 0.625rem;
    color: #7a9299;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    margin-top: 0.25rem;
  }

  .time-separator {
    font-size: 1.25rem;
    font-weight: 700;
    color: #7a9299;
    margin-bottom: 1rem;
  }

  .countdown-expired {
    color: #e8eeef;
    font-weight: 600;
  }
</style>
