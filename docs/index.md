---
layout: default
---

{% include icon-header.html %}

<div class="showcase">
    <div class="showcase-container">
        <div class="showcase-scroll">
            <div class="showcase-item">
                {% include picture.html light="/images/screenshot-default@2x.png" dark="/images/screenshot-default-dark@2x.png" %}
            </div>
            <div class="showcase-item">
                {% include picture.html light="/images/screenshot-where@2x.png" dark="/images/screenshot-where-dark@2x.png" %}
            </div>
        </div>
        <div class="showcase-dots"></div>
    </div>
</div>

<div class="content center">
    <ul class="features">
        <li>
            <p><img class="symbol" src="/images/calendar.svg" /></p>
            <p><strong>Monthly Summaries</strong></p>
            <p>Get an at-a-glance overview of how you spend your time each month.</p>
        </li>
        <li>
            <p><img class="symbol" src="/images/clock.svg" /></p>
            <p><strong>Discover Patterns</strong></p>
            <p>Quickly identify tasks taking too much time, or ones that need a little more love.</p>
        </li>
        <li>
            <p><img class="symbol" src="/images/globe.svg" /></p>
            <p><strong>Reporting</strong></p>
            <p>Use all-day calendar entries for daily location and task tracking and reporting.</p>
        </li>
        <li>
            <p><img class="symbol" src="/images/17.calendar.svg" /></p>
            <p><strong>Apple Calendar Integration</strong></p>
            <p>Use any account connected to Apple Calendar on your Mac.</p>
        </li>
    </ul>
</div>

<script type="module" src="/assets/js/showcase-carousel.js"></script>
