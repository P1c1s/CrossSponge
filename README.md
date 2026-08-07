# Cross Sponge

Cross Sponge è un crittosistema scalabile in quanto lo stato interno può avere diverse dimensione a patto che si rspetti una dimensione di elementi pari al quadrato di un numero pari.Si basa sulle sponge function, per garantire un'elevata diffusione e non-linearità dei dati ad ogni round.

### Fasi 
Si componse di due fasi:
- warm-up: cross + ...
- assorbimento ...

### Permutazioni

Layer di Sostituzione Non Lineare (SubstitutionLayer): rappresenta la S-Box non lineare del cifrario. Divide lo stato $N \times N$ in 4 quadranti ($q_{TL}, q_{TR}, q_{BL}, q_{BR}$) e applica una trasformazione algebrica in $\mathbb{F}_2$. 
- $q_{TL} = q_{TL} \oplus q_{TL} \cdot q_{BR}$
- $q_{TR} = q_{TR} \oplus q_{TR} \cdot q_{BL}$
- $q_{BL} = q_{BL} \oplus q_{BL} \cdot q_{TR}$
- $q_{BR} = q_{BR} \oplus q_{BR} \cdot q_{TL}$

Layer di Diffusione Lineare (DiffiusionLayer): garantisce la diffusione orizzontale delle informazioni all'interno dello stato. Applica una traslazione circolare a sinistra di passo $N/2$ a ciascuna riga della matrice dello stato.Assicura che i bit di differenti quadranti si mescolino tra loro nei round successivi.

- $r_1 <<< \frac{N}2$
- $r_2 <<< \frac{N}2$
- $r_3 <<< \frac{N}2$
- $r_4 <<< \frac{N}2$


![Schema Cross Sponge](schema.drawio.png)
