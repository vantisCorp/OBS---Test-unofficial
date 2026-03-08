# Faza 4 - Plan Rozwoju: Optymalizacje Hot Paths

## Cel
Implementacja optymalizacji zidentyfikowanych w HOT_PATHS.md na podstawie wyników benchmarków.

## Propozycje implementacji

### 1. SIMD Audio Mixing (Priorytet: Wysoki)
**Plik**: `libobs/obs-audio.c`

**Cel**: Wykorzystanie instrukcji SIMD (SSE/AVX) do miksowania audio.

**Korzyści**:
- 4-8x szybsze miksowanie próbek audio
- Mniejsze obciążenie CPU przy wielu źródłach audio

**Implementacja**:
```c
// Wykorzystanie SIMDe dla przenośności
#include <simde/x86/sse.h>

void mix_audio_simd(float *dest, const float *src, size_t frames) {
    for (size_t i = 0; i < frames; i += 4) {
        simde__m128 d = simde_mm_loadu_ps(&dest[i]);
        simde__m128 s = simde_mm_loadu_ps(&src[i]);
        simde_mm_storeu_ps(&dest[i], simde_mm_add_ps(d, s));
    }
}
```

---

### 2. Lock-Free Audio Queue (Priorytet: Wysoki)
**Plik**: `libobs/obs-audio.c`

**Cel**: Zastąpienie mutex-protected queue lock-free implementacją.

**Korzyści**:
- Eliminacja lock contention w audio pipeline
- Bardziej stabilne audio przy wysokim obciążeniu

**Implementacja**:
- Single Producer Single Consumer (SPSC) queue
- Atomic operations z memory barriers

---

### 3. Source Render Cache (Priorytet: Średni)
**Plik**: `libobs/obs-source.c`

**Cel**: Cache'owanie często używanych właściwości source.

**Korzyści**:
- Mniejsza liczba dereferencji w hot path
- Lepsza lokalność danych cache CPU

**Implementacja**:
```c
struct obs_source_cache {
    bool active;
    bool showing;
    uint32_t flags;
    uint32_t last_check_ms;
};
```

---

### 4. Hash Table dla obs_data (Priorytet: Średni)
**Status**: Wymaga reimplementacji z brancha hash-table

**Cel**: Zamiana linked list na hash table w obs_data.

**Korzyści**:
- Wyszukiwanie O(1) zamiast O(n)
- Znacząca poprawa dla dużych obiektów JSON

---

### 5. GPU Frame Upload (Priorytet: Niski)
**Pliki**: `libobs/graphics/`

**Cel**: Wykorzystanie GPU do format conversion.

**Korzyści**:
- Odciążenie CPU przy konwersji formatów
- Mniejsze opóźnienia przy renderingu

---

## Metryki sukcesu

| Metryka | Baseline | Cel |
|---------|----------|-----|
| Audio mixing CPU | X% | X/2% |
| obs_data_get() latency | O(n) | O(1) |
| Source render time | X ms | X*0.8 ms |
| Frame drops przy 60fps | Y | Y/2 |

---

## Harmonogram

| Tydzień | Zadanie |
|---------|---------|
| 1 | SIMD Audio Mixing implementation |
| 2 | Lock-Free Audio Queue |
| 3 | Source Render Cache |
| 4 | Hash Table reimplementation |
| 5 | Testy i benchmarki |
| 6 | Dokumentacja i PR |

---

*Autor: SuperNinja AI Agent*
*Data: 2026-03-08*