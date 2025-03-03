# React Quiz App - Step-by-Step Guide  

## Motivace

### Pro� React?

#### 1. Snadn� tvorba interaktivn�ch aplikac�
* React umo��uje vytv��et rychl�, dynamick� a interaktivn� u�ivatelsk� rozhran�.
* Komponentov� p��stup � aplikaci rozlo��te na mal�, znovupou�iteln� ��sti (nap�. `Quiz`, `Question`, `Button`).
* Jednoduch� spravov�n� stavu aplikace pomoc� `useState` a `useEffect`.

#### 2. Rychl� a efektivn� d�ky Virtual DOM
* React nep�episuje cel� HTML k�d p�i ka�d� zm�n�, ale chyt�e aktualizuje jen zm�n�n� ��sti d�ky Virtual DOM.
* V�sledkem je rychlej�� a efektivn�j�� aplikace oproti klasick�mu manipulov�n� s `document.getElementById()`.

#### 3. Snadn� roz�i�itelnost a ekosyst�m
* React m� obrovskou komunitu, co� znamen� hodn� n�vod�, knihoven a n�stroj�.
* Lze ho propojit s dal��mi technologiemi, jako je Redux, TailwindCSS, Firebase, MongoDB, Express.js.
* React Native umo��uje ps�t mobiln� aplikace stejnou syntax� jako webovou aplikaci!

#### 4. Pou�it� ve firm�ch a re�ln�ch projektech
* Velk� firmy jako Meta, Netflix, Airbnb, Spotify, Uber pou��vaj� React.
* Pokud pl�nujete kari�ru v programov�n�, znalost Reactu zv��� va�e �ance na zam�stn�n�.

### Pro� pou��t Vite?
* Rychlej�� setup a build time d�ky tomu, �e pou��v� ES modules (ESM).
* Instant Hot Module Replacement (HMR)
* Jednoduch� konfigurace (pouze `vite.config.js`)

## P��prava projektu  

### 1. Vytvo�en� React aplikace:  
   ```sh
   npm create vite@latest quiz-app -- --template react
   cd quiz-app
   npm install
   npm run dev
   ```
Program nyn� b�� na adrese [http://localhost:5173](http://localhost:5173):


![Vite React](images/screenshot1.png "sample page")

### 2. Struktura projektu a �prava soubor�
![Project Structure](images/screenshot2.png "project structure")
